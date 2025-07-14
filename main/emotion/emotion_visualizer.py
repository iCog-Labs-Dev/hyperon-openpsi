from hyperon import MeTTa
import matplotlib.pyplot as plt
metta = MeTTa()

metta.run("""
!(register-module! ../../../hyperon-openpsi)
!(register-module! ../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:main:emotion:emotion)
""")

metta.run("""
!(create-emotion &emotion-space (emotion happiness 0.3))
!(create-emotion &emotion-space (emotion anger 0.7))
""")

emotions = metta.run('''
!(match &emotion-space (emotion $x $y) ($x $y))
''')[0]
emotion_list = []
emotion_list_value = []
for e in emotions:
    child = e.get_children()[0]
    child_value = e.get_children()[1]
    emotion_list.append(str(child))
    emotion_list_value.append(float(str(child_value)))


def plot_emotions(label , values):
    plt.bar(label, values , color='skyblue')

    plt.title('emotion visulization')
    plt.xlabel('emotions')
    plt.ylabel('values')

    plt.tight_layout()
    plt.show()
plot_emotions(emotion_list , emotion_list_value)






