"""
Speech-to-Text module for the Curious Agent.
Provides multiple STT backends including Google Speech Recognition, Whisper, and microphone recording.
"""

import os
import time
import threading
import queue
import wave
import tempfile
from typing import Optional, Callable, Dict, Any
import logging
import sys
import array
import ctypes
import ctypes.util

# Speech recognition imports
import speech_recognition as sr
import pyaudio
 

# Configure logging (default WARNING; override via STT_LOG_LEVEL)
_log_level_name = os.getenv("STT_LOG_LEVEL", "WARNING").upper()
_log_level = getattr(logging, _log_level_name, logging.WARNING)
logging.basicConfig(level=_log_level)
logger = logging.getLogger(__name__)

# Low-level silencing of ALSA/JACK/Pulse errors printed to stderr by native libs
_alsa_err_cb_ref = None
def _install_alsa_error_silencer():
    global _alsa_err_cb_ref
    try:
        lib_name = ctypes.util.find_library('asound')
        if not lib_name:
            return
        asound = ctypes.CDLL(lib_name)
        # typedef void (*snd_lib_error_handler_t)(const char *file, int line, const char *function, int err, const char *fmt, ...);
        HANDLER = ctypes.CFUNCTYPE(None, ctypes.c_char_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_int, ctypes.c_char_p)
        def _noerr(file, line, func, err, fmt):
            return None
        _alsa_err_cb_ref = HANDLER(_noerr)  # keep reference to avoid GC
        try:
            asound.snd_lib_error_set_handler.argtypes = [HANDLER]
        except Exception:
            pass
        asound.snd_lib_error_set_handler(_alsa_err_cb_ref)
    except Exception:
        # Best-effort; ignore if not available
        pass

# Install native ALSA silencer as early as possible
_install_alsa_error_silencer()

# Suppress ALSA error messages by redirecting stderr temporarily during audio operations (Python-layer)
class ALSAErrorSuppressor:
    def __enter__(self):
        # Save Python-level streams
        self._orig_stderr = sys.stderr
        self._orig_stdout = sys.stdout

        # Save native fds
        self._stderr_fd = os.dup(2)
        self._stdout_fd = os.dup(1)

        # Open /dev/null and redirect both Python streams and native fds
        self._null = os.open(os.devnull, os.O_RDWR)
        sys.stderr = open(os.devnull, 'w')
        sys.stdout = open(os.devnull, 'w')
        try:
            os.dup2(self._null, 2)
            os.dup2(self._null, 1)
        except Exception:
            pass
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            # Restore native fds
            os.dup2(self._stderr_fd, 2)
            os.dup2(self._stdout_fd, 1)
        except Exception:
            pass
        # Close temp fds
        try:
            os.close(self._stderr_fd)
        except Exception:
            pass
        try:
            os.close(self._stdout_fd)
        except Exception:
            pass
        try:
            os.close(self._null)
        except Exception:
            pass
        # Restore Python-level streams
        try:
            sys.stderr.close()
        except Exception:
            pass
        try:
            sys.stdout.close()
        except Exception:
            pass
        sys.stderr = self._orig_stderr
        sys.stdout = self._orig_stdout

# Set environment variables to suppress ALSA warnings globally
os.environ.setdefault('ALSA_CARD', '0')
os.environ.setdefault('ALSA_DEVICE', '0')
os.environ.setdefault('PULSE_SERVER', 'unix:/tmp/pulse-socket')
os.environ.setdefault('JACK_NO_START_SERVER', '1')

def pick_input_device(p: pyaudio.PyAudio):
    """
    Return a tuple (device_index, suggested_sample_rate) for a usable input device.
    Prefers default input, then PulseAudio/USB/Microphone devices, then first capture device.
    """
    try:
        # Env overrides
        env_device = os.getenv("STT_DEVICE_INDEX")
        env_rate = os.getenv("STT_SAMPLE_RATE")

        # Try default input device first
        default_idx = None
        try:
            default_idx = p.get_default_input_device_info().get("index", None)
            logger.debug(f"Default input index: {default_idx}")
        except Exception:
            default_idx = None

        candidates = []
        for i in range(p.get_device_count()):
            info = p.get_device_info_by_index(i)
            if info.get("maxInputChannels", 0) > 0:
                candidates.append((i, info))
        logger.debug(f"Input candidates: {[(i, inf['name']) for i, inf in candidates]}")

        # Helper to extract name and rate
        def info_tuple(t):
            idx, inf = t
            name = inf.get("name", "")
            rate = int(inf.get("defaultSampleRate", 16000))
            return idx, name, rate

        # If env specifies a device, honor it if valid
        if env_device is not None:
            try:
                env_idx = int(env_device)
                inf = p.get_device_info_by_index(env_idx)
                if inf.get("maxInputChannels", 0) > 0:
                    chosen_rate = int(env_rate) if env_rate else int(inf.get("defaultSampleRate", 16000))
                    return env_idx, chosen_rate
            except Exception:
                pass

        # 1) Prefer PulseAudio/PipeWire explicitly if available (tends to be most reliable)
        for idx, name, rate in map(info_tuple, candidates):
            lname = str(name).lower()
            if any(keyword in lname for keyword in ["pulse", "pipewire", "default"]):
                return idx, rate

        # 2) Default input
        if default_idx is not None:
            inf = p.get_device_info_by_index(default_idx)
            return default_idx, int(inf.get("defaultSampleRate", 16000))

        # 3) Prefer common capture device names
        for idx, name, rate in map(info_tuple, candidates):
            lname = str(name).lower()
            if any(k in lname for k in ["microphone", "usb", "headset", "realtek", "alc"]):
                return idx, rate

        # 4) Fallback: first capture device
        if candidates:
            idx, inf = candidates[0]
            return idx, int(inf.get("defaultSampleRate", 16000))

        return None, 16000
    except Exception as e:
        logger.error(f"Error picking input device: {e}")
        return None, 16000

class SpeechToTextEngine:
    """
    A comprehensive speech-to-text engine with multiple backends and real-time capabilities.
    """
    
    def __init__(self, 
                 backend: str = "google", 
                 language: str = "en-US",
                 whisper_model: str = "base",
                 energy_threshold: int = 300,
                 pause_threshold: float = 0.8,
                 phrase_threshold: float = 0.3):
        """
        Initialize the STT engine.
        
        Args:
            backend: STT backend to use ("google", "whisper", "offline")
            language: Language code for speech recognition
            whisper_model: Whisper model size ("tiny", "base", "small", "medium", "large")
            energy_threshold: Energy level for speech detection
            pause_threshold: Seconds of silence before considering speech complete
            phrase_threshold: Minimum seconds of speaking audio before considering phrase
        """
        self.backend = backend
        self.language = language
        self.whisper_model = whisper_model
        self.energy_threshold = energy_threshold
        self.pause_threshold = pause_threshold
        self.phrase_threshold = phrase_threshold
        
        # Initialize recognizer
        self.recognizer = sr.Recognizer()
        
        # Configure recognizer settings
        self.recognizer.energy_threshold = energy_threshold
        self.recognizer.pause_threshold = pause_threshold
        self.recognizer.phrase_threshold = phrase_threshold
        
        # Whisper backend disabled to simplify pipeline
        self.whisper_model_obj = None
        
        # Setup microphone robustly
        self.microphone = None
        p = None
        try:
            with ALSAErrorSuppressor():
                p = pyaudio.PyAudio()
        except Exception as e:
            logger.warning(f"PyAudio initialization warning (may be normal): {e}")
            # Try again without error suppression to get the actual error if needed
            try:
                p = pyaudio.PyAudio()
            except Exception as e2:
                logger.error(f"PyAudio initialization failed: {e2}")
                raise RuntimeError(f"Could not initialize audio system: {e2}")
        
        try:
            preferred_idx, preferred_rate = pick_input_device(p)
            
            # Simplified device selection to prevent crashes
            device_candidates = []
            
            # Get all input devices
            for i in range(p.get_device_count()):
                try:
                    info = p.get_device_info_by_index(i)
                    if info.get("maxInputChannels", 0) > 0:
                        device_candidates.append((i, info))
                except Exception:
                    continue
            
            # Sort devices by preference
            device_priority = []
            for idx, info in device_candidates:
                name = str(info.get("name", "")).lower()
                if "pulse" in name or "default" in name:
                    device_priority.insert(0, (idx, info))  # High priority
                elif "hw:" in name:
                    device_priority.append((idx, info))  # Medium priority
                else:
                    device_priority.append((idx, info))  # Low priority
            
            # Add system default as last resort
            device_priority.append((None, {"name": "System Default"}))
            
            logger.info(f"Found {len(device_candidates)} input devices, trying in priority order...")
            
            # Try devices with simplified approach
            for dev_idx, dev_info in device_priority[:3]:  # Limit to first 3 devices to prevent crashes
                try:
                    logger.info(f"Trying device {dev_idx} ({dev_info.get('name', 'Default')})")
                    
                    with ALSAErrorSuppressor():
                        # Use default sample rate and minimal configuration
                        mic = sr.Microphone(device_index=dev_idx, sample_rate=16000, chunk_size=1024)
                        
                        # Quick test - just try to open the microphone
                        with mic as _src:
                            pass
                        
                        # Skip calibration to prevent crashes
                        self.recognizer.energy_threshold = 300  # Use default threshold
                        
                        logger.info(f"Success! Using device {dev_idx} ({dev_info.get('name', 'System Default')}) at 16000 Hz, threshold 300")
                        self.microphone = mic
                        break
                        
                except Exception as e:
                    logger.debug(f"Failed for device {dev_idx}: {e}")
                    continue
        finally:
            with ALSAErrorSuppressor():
                p.terminate()

        if not self.microphone:
            # Last resort: try to create a microphone without validation
            logger.warning("No microphone found through validation, trying fallback approach...")
            try:
                with ALSAErrorSuppressor():
                    # Try the default device without validation
                    self.microphone = sr.Microphone()
                    logger.info("Fallback: Using default microphone without validation")
            except Exception as e:
                logger.error(f"Fallback microphone creation failed: {e}")
                raise RuntimeError("No usable microphone found. Check audio setup, permissions, and devices.")

        # Override energy threshold if provided
        if energy_threshold:
            self.recognizer.energy_threshold = energy_threshold
        
        # Real-time processing
        self.is_listening = False
        self.audio_queue = queue.Queue()
        self.result_queue = queue.Queue()
        self.stop_listening = None
        
    def transcribe_audio_file(self, audio_file_path: str) -> Optional[str]:
        """
        Transcribe an audio file using the configured backend.
        
        Args:
            audio_file_path: Path to the audio file
            
        Returns:
            Transcribed text or None if transcription failed
        """
        try:
            return self._transcribe_with_google_file(audio_file_path)
        except Exception as e:
            logger.error(f"Transcription failed: {e}")
            return None
    
    def _transcribe_with_google_file(self, audio_file_path: str) -> Optional[str]:
        """Transcribe audio file using Google Speech Recognition."""
        try:
            with sr.AudioFile(audio_file_path) as source:
                audio = self.recognizer.record(source)
            
            if self.backend == "google":
                return self.recognizer.recognize_google(audio, language=self.language)
            else:
                # Fallback to Google if other backend fails
                return self.recognizer.recognize_google(audio, language=self.language)
        except sr.UnknownValueError:
            logger.warning("Could not understand audio")
            return None
        except sr.RequestError as e:
            logger.error(f"Could not request results from speech recognition service: {e}")
            return None
    
    def listen_once(self, timeout: Optional[float] = None, phrase_time_limit: Optional[float] = None) -> Optional[str]:
        """
        Listen for speech once and return the transcribed text.
        
        Args:
            timeout: Maximum time to wait for speech to start
            phrase_time_limit: Maximum time to wait for phrase to complete
            
        Returns:
            Transcribed text or None if no speech detected
        """
        try:
            logger.info("Listening for speech...")
            with ALSAErrorSuppressor():
                with self.microphone as source:
                    # Brief ambient calibration to improve recognition stability
                    try:
                        self.recognizer.dynamic_energy_threshold = True
                        self.recognizer.adjust_for_ambient_noise(source, duration=0.3)
                    except Exception:
                        pass
                    if timeout:
                        audio = self.recognizer.listen(source, timeout=timeout, phrase_time_limit=phrase_time_limit)
                    else:
                        audio = self.recognizer.listen(source, phrase_time_limit=phrase_time_limit)
            
            return self._transcribe_audio(audio)
        except sr.WaitTimeoutError:
            logger.info("No speech detected within timeout period")
            return None
        except Exception as e:
            logger.error(f"Error during listening: {e}")
            return None
    
    def _transcribe_audio(self, audio: sr.AudioData) -> Optional[str]:
        """Transcribe audio data using the configured backend."""
        try:
            text = self._transcribe_with_google_audio(audio)

            # Echo recognized text immediately (before any downstream chatbot prints)
            if text and os.getenv("STT_ECHO", "1") == "1":
                print(f"🗣️ STT: {text}")
                sys.stdout.flush()
            
            return text
        except Exception as e:
            logger.error(f"Transcription failed: {e}")
            return None
    
    def _transcribe_with_google_audio(self, audio: sr.AudioData) -> Optional[str]:
        """Transcribe audio data using Google Speech Recognition."""
        try:
            return self.recognizer.recognize_google(audio, language=self.language)
        except sr.UnknownValueError:
            logger.warning("Could not understand audio")
            return None
        except sr.RequestError as e:
            logger.error(f"Could not request results from speech recognition service: {e}")
            return None
    
    def start_continuous_listening(self, callback: Callable[[str], None]):
        """
        Start continuous listening for speech.
        
        Args:
            callback: Function to call when speech is detected and transcribed
        """
        if self.is_listening:
            logger.warning("Already listening continuously")
            return
        
        self.is_listening = True
        logger.info("Starting continuous listening...")
        
        def audio_callback(recognizer, audio):
            """Callback for continuous listening."""
            if not self.is_listening:
                return
            
            try:
                text = self._transcribe_audio(audio)
                if text:
                    callback(text)
            except Exception as e:
                logger.error(f"Error in audio callback: {e}")
        
        # Start listening in the background; guard against device/open errors
        try:
            with ALSAErrorSuppressor():
                self.stop_listening = self.recognizer.listen_in_background(
                    self.microphone,
                    audio_callback,
                    phrase_time_limit=5,
                )
        except Exception as e:
            self.is_listening = False
            logger.error(f"Failed to start background listening: {e}")
    
    def stop_continuous_listening(self):
        """Stop continuous listening."""
        if not self.is_listening:
            return
        
        self.is_listening = False
        if self.stop_listening:
            self.stop_listening(wait_for_stop=False)
            self.stop_listening = None
        logger.info("Stopped continuous listening")
    
    def record_audio(self, duration: float = 5.0, output_file: Optional[str] = None) -> str:
        """
        Record audio for a specified duration.
        
        Args:
            duration: Duration to record in seconds
            output_file: Optional output file path. If None, creates a temporary file.
            
        Returns:
            Path to the recorded audio file
        """
        if output_file is None:
            temp_file = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
            output_file = temp_file.name
            temp_file.close()
        
        try:
            logger.info(f"Recording audio for {duration} seconds...")
            
            # Set up PyAudio
            # Use larger chunks to reduce overflow pressure and align loops with actual device rate
            chunk = 2048
            format = pyaudio.paInt16
            channels = 1
            default_rate = 16000
            
            with ALSAErrorSuppressor():
                audio = pyaudio.PyAudio()
                
                # Open stream (select same input device and compatible rate)
                dev_idx, dev_rate = pick_input_device(audio)
                effective_rate = int(dev_rate) if dev_rate else default_rate
                try:
                    stream = audio.open(
                        format=format,
                        channels=channels,
                        rate=effective_rate,
                        input=True,
                        input_device_index=dev_idx,
                        frames_per_buffer=chunk,
                    )
                except Exception:
                    # Fallback to default device/rate
                    effective_rate = default_rate
                    stream = audio.open(
                        format=format,
                        channels=channels,
                        rate=effective_rate,
                        input=True,
                        frames_per_buffer=chunk,
                    )
            
            frames = []
            
            # Record using overflow-tolerant reads. Loop count uses the actual effective_rate
            total_chunks = int(effective_rate / chunk * duration)
            for _ in range(total_chunks):
                try:
                    data = stream.read(chunk, exception_on_overflow=False)
                except Exception:
                    # In case of intermittent overflow, append silence of the same size
                    data = b"\x00" * (chunk * 2)  # 16-bit samples
                frames.append(data)
            
            # Stop recording
            with ALSAErrorSuppressor():
                stream.stop_stream()
                stream.close()
                audio.terminate()
            
            # Save to file
            with wave.open(output_file, 'wb') as wf:
                wf.setnchannels(channels)
                wf.setsampwidth(audio.get_sample_size(format))
                wf.setframerate(effective_rate)
                wf.writeframes(b''.join(frames))
            
            logger.info(f"Audio recorded to: {output_file}")
            return output_file
            
        except Exception as e:
            logger.error(f"Error recording audio: {e}")
            raise
    
    # Removed audio playback to simplify pipeline

# Backwards-compatibility minimal stub. Some modules import InteractiveSTT.
class InteractiveSTT:
    def __init__(self, stt_engine: SpeechToTextEngine):
        self.stt_engine = stt_engine

    # No interactive loop; provide a simple one-shot input helper
    def get_speech_input(self, prompt: str = "Speak now:") -> Optional[str]:
        return self.stt_engine.listen_once(timeout=10000000.0, phrase_time_limit=1000000.0)

    # Lightweight continuous loop for compatibility with callers expecting persistence
    def start_interactive_mode(self, on_text: Optional[Callable[[str], None]] = None):
        try:
            while True:
                text = self.stt_engine.listen_once(timeout=100.0, phrase_time_limit=100.0)
                if text and on_text:
                    try:
                        on_text(text)
                    except Exception:
                        pass
        except KeyboardInterrupt:
            pass

# Convenience functions for easy integration
def create_stt_engine(backend: str = "google", language: str = "en-US") -> SpeechToTextEngine:
    """Create a configured STT engine."""
    return SpeechToTextEngine(backend=backend, language=language)


def create_interactive_stt(backend: str = "google", language: str = "en-US") -> InteractiveSTT:
    """Create an interactive STT interface."""
    engine = create_stt_engine(backend, language)
    return InteractiveSTT(engine)


def test_audio_system():
    """Test the audio system and provide diagnostic information."""
    print("🔍 Testing audio system...")
    
    try:
        with ALSAErrorSuppressor():
            p = pyaudio.PyAudio()
        
        print(f"PyAudio initialized successfully")
        print(f"Found {p.get_device_count()} audio devices:")
        
        input_devices = []
        for i in range(p.get_device_count()):
            info = p.get_device_info_by_index(i)
            if info.get("maxInputChannels", 0) > 0:
                input_devices.append((i, info))
                print(f"  🎤 Input {i}: {info['name']} (channels: {info['maxInputChannels']}, rate: {info['defaultSampleRate']})")
        
        if not input_devices:
            print(" No input devices found!")
            return False
        
        # Test device selection
        preferred_idx, preferred_rate = pick_input_device(p)
        if preferred_idx is not None:
            print(f" Selected device {preferred_idx} at {preferred_rate} Hz")
        else:
            print("  Could not select a preferred device")
        
        p.terminate()
        return True
        
    except Exception as e:
        print(f" Audio system test failed: {e}")
        return False


def setup_stable_environment():
    """Set up environment variables for maximum stability."""
    # Set environment variables to suppress ALL audio warnings
    os.environ['ALSA_CARD'] = '0'
    os.environ['ALSA_DEVICE'] = '0'
    os.environ['PULSE_SERVER'] = 'unix:/tmp/pulse-socket'
    os.environ['ALSA_CONF'] = '/dev/null'
    os.environ['PULSE_RUNTIME_PATH'] = '/tmp'
    os.environ['PULSE_STATE_PATH'] = '/tmp'
    os.environ['ALSA_DEBUG'] = '0'
    os.environ['ALSA_VERBOSE'] = '0'
    
    logger.info("🔧 Environment configured for maximum stability")


def check_metta():
    return False


def run_curious_agent_stable():
    return False


if __name__ == "__main__":
    print("This module provides SpeechToTextEngine and InteractiveSTT. Import and use from your agent.")