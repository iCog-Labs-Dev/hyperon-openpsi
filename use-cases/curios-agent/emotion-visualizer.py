from hyperon import *
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import random

metta = MeTTa()

metta.run("""
!(register-module! ../../../hyperon-openpsi)
!(register-module! ../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:main:emotion:emotion)
!(bind! &emotion-space (new-space))
""")

s = metta.run("""
!(create-emotion &emotion-space (emotion happiness 0.3))
!(create-emotion &emotion-space (emotion anger 0.7))
""")
print(s)
def update_emotions():
    emotions = metta.run('!(get-emotions &emotion-space)')[0]
    for e in emotions[0].get_children():
        emotion_name = str(e.get_children()[1])
        # Randomly update the emotion value to a new value between 0 and 1 
        new_val = round(random.uniform(0, 1), 2)
        # adds this value to the emotion space
        metta.run(f'!(create-emotion &emotion-space (emotion {S(emotion_name)} {S(str(new_val))}))')

def fetch_emotions():
    emotions = metta.run('!(get-emotions &emotion-space)')[0]
    emotion_list = []
    emotion_list_value = []
    for e in emotions[0].get_children():
        emotion_list.append(str(e.get_children()[1]))
        emotion_list_value.append(float(str(e.get_children()[2])))
    return emotion_list, emotion_list_value

fig, ax = plt.subplots()

def animate(frame):
    update_emotions()

    labels, values = fetch_emotions()

    ax.clear()
    ax.bar(labels, values, color='skyblue')
    ax.set_ylim(0, 1) 
    ax.set_title('Real-Time Emotion Visualization')
    ax.set_xlabel('Emotions')
    ax.set_ylabel('Values')
    plt.tight_layout()

ani = animation.FuncAnimation(fig, animate, interval=1000)

plt.show()
