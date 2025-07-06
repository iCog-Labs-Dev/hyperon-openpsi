import sys
import os

# Add the project root directory to the Python path
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from openPsi import *

def test_correlate():
    rules = [
                "(: R1 (IMPLICATION_LINK (AND_LINK ((Conversation-Started)) (Greet-Human)) (Initiate-Engagement)) (TTV 100 (STV 0.9 0.8)))",
                "(: R2 (IMPLICATION_LINK (AND_LINK ((Human-Responds-To-Greeting)) (Ask-About-Human’s-Day)) (Learn-About-Daily-Activities)) (TTV 101 (STV 0.9 0.8)))",
                "(: R3 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Activity)) (Ask-For-Activity-Details)) (Understand-Activity-Context)) (TTV 102 (STV 0.9 0.8)))",
                "(: R4 (IMPLICATION_LINK (AND_LINK ((Human-Provides-Short-Answer)) (Ask-Follow-Up-Question)) (Deepen-Conversation)) (TTV 103 (STV 0.9 0.8)))",
                "(: R5 (IMPLICATION_LINK (AND_LINK ((Human-Provides-Detailed-Answer)) (Express-Interest)) (Show-Engagement)) (TTV 104 (STV 0.9 0.8)))",
                "(: R6 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Hobby)) (Ask-Why-Human-Enjoys-Hobby)) (Learn-About-Hobby)) (TTV 105 (STV 0.9 0.8)))",
                "(: R7 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Work)) (Inquire-About-Job-Role)) (Understand-Job-Context)) (TTV 106 (STV 0.9 0.8)))",
                "(: R8 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Family)) (Ask-About-Family-Members)) (Learn-About-Family)) (TTV 107 (STV 0.9 0.8)))",
                "(: R9 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Travel)) (Ask-About-Favorite-Destination)) (Explore-Travel-Interests)) (TTV 108 (STV 0.9 0.8)))",
                "(: R10 (IMPLICATION_LINK (AND_LINK ((Human-Shares-Story)) (Ask-For-Story-Context)) (Understand-Narrative)) (TTV 109 (STV 0.9 0.8)))",
                "(: R11 (IMPLICATION_LINK (AND_LINK ((Human-Expresses-Happiness)) (Share-Positive-Response)) (Reinforce-Positivity)) (TTV 110 (STV 0.9 0.8)))",
                "(: R12 (IMPLICATION_LINK (AND_LINK ((Human-Expresses-Sadness)) (Offer-Empathy)) (Provide-Emotional-Support)) (TTV 111 (STV 0.9 0.8)))",
                "(: R13 (IMPLICATION_LINK (AND_LINK ((Human-Asks-Question)) (Provide-Informative-Answer)) (Satisfy-Curiosity)) (TTV 112 (STV 0.9 0.8)))",
                "(: R14 (IMPLICATION_LINK (AND_LINK ((Human-Asks-Complex-Question)) (Break-Down-Question)) (Clarify-Inquiry)) (TTV 113 (STV 0.9 0.8)))",
                "(: R15 (IMPLICATION_LINK (AND_LINK ((Human-Provides-Ambiguous-Answer)) (Seek-Clarification)) (Resolve-Ambiguity)) (TTV 114 (STV 0.9 0.8)))",
                "(: R16 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Book)) (Ask-About-Book-Theme)) (Explore-Literary-Interests)) (TTV 115 (STV 0.9 0.8)))",
                "(: R17 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Movie)) (Inquire-About-Movie-Genre)) (Learn-About-Film-Preferences)) (TTV 116 (STV 0.9 0.8)))",
                "(: R18 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Music)) (Ask-About-Favorite-Artist)) (Understand-Music-Taste)) (TTV 117 (STV 0.9 0.8)))",
                "(: R19 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Food)) (Ask-About-Favorite-Dish)) (Explore-Culinary-Preferences)) (TTV 118 (STV 0.9 0.8)))",
                "(: R20 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Technology)) (Inquire-About-Tech-Interests)) (Learn-About-Tech)) (TTV 119 (STV 0.9 0.8)))",
                "(: R21 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Science)) (Ask-About-Specific-Field)) (Explore-Scientific-Interests)) (TTV 120 (STV 0.9 0.8)))",
                "(: R22 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-History)) (Ask-About-Historical-Period)) (Learn-About-History)) (TTV 121 (STV 0.9 0.8)))",
                "(: R23 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Art)) (Inquire-About-Art-Style)) (Understand-Art-Preferences)) (TTV 122 (STV 0.9 0.8)))",
                "(: R24 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Sports)) (Ask-About-Favorite-Team)) (Explore-Sports-Interests)) (TTV 123 (STV 0.9 0.8)))",
                "(: R25 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Game)) (Ask-About-Game-Type)) (Learn-About-Gaming)) (TTV 124 (STV 0.9 0.8)))",
                "(: R26 (IMPLICATION_LINK (AND_LINK ((Human-Shares-Opinion)) (Ask-For-Reasoning)) (Understand-Opinion-Basis)) (TTV 125 (STV 0.9 0.8)))",
                "(: R27 (IMPLICATION_LINK (AND_LINK ((Human-Expresses-Confusion)) (Simplify-Explanation)) (Clarify-Concept)) (TTV 126 (STV 0.9 0.8)))",
                "(: R28 (IMPLICATION_LINK (AND_LINK ((Human-Changes-Topic)) (Acknowledge-New-Topic)) (Follow-Topic-Shift)) (TTV 127 (STV 0.9 0.8)))",
                "(: R29 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Goal)) (Ask-About-Steps-To-Goal)) (Learn-About-Goals)) (TTV 128 (STV 0.9 0.8)))",
                "(: R30 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Challenge)) (Inquire-About-Overcoming-Challenge)) (Understand-Challenges)) (TTV 129 (STV 0.9 0.8)))",
                "(: R31 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Success)) (Congratulate-Human)) (Celebrate-Success)) (TTV 130 (STV 0.9 0.8)))",
                "(: R32 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Failure)) (Offer-Encouragement)) (Provide-Motivation)) (TTV 131 (STV 0.9 0.8)))",
                "(: R33 (IMPLICATION_LINK (AND_LINK ((Human-Asks-For-Advice)) (Provide-Thoughtful-Advice)) (Offer-Guidance)) (TTV 132 (STV 0.9 0.8)))",
                "(: R34 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Culture)) (Ask-About-Cultural-Practices)) (Learn-About-Culture)) (TTV 133 (STV 0.9 0.8)))",
                "(: R35 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Nature)) (Inquire-About-Favorite-Place)) (Explore-Nature-Interests)) (TTV 134 (STV 0.9 0.8)))",
                "(: R36 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Weather)) (Ask-About-Weather-Preferences)) (Understand-Weather-Views)) (TTV 135 (STV 0.9 0.8)))",
                "(: R37 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Education)) (Ask-About-Learning-Experience)) (Learn-About-Education)) (TTV 136 (STV 0.9 0.8)))",
                "(: R38 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Health)) (Inquire-About-Wellness-Habits)) (Understand-Health-Practices)) (TTV 137 (STV 0.9 0.8)))",
                "(: R39 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Fitness)) (Ask-About-Exercise-Routine)) (Learn-About-Fitness)) (TTV 138 (STV 0.9 0.8)))",
                "(: R40 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Diet)) (Ask-About-Favorite-Foods)) (Explore-Diet-Preferences)) (TTV 139 (STV 0.9 0.8)))",
                "(: R41 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Pet)) (Ask-About-Pet-Details)) (Learn-About-Pets)) (TTV 140 (STV 0.9 0.8)))",
                "(: R42 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Vacation)) (Inquire-About-Vacation-Plans)) (Explore-Vacation-Ideas)) (TTV 141 (STV 0.9 0.8)))",
                "(: R43 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-News)) (Ask-About-News-Source)) (Understand-News-Interests)) (TTV 142 (STV 0.9 0.8)))",
                "(: R44 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Politics)) (Ask-About-Political-Views)) (Learn-About-Politics)) (TTV 143 (STV 0.9 0.8)))",
                "(: R45 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Religion)) (Inquire-About-Beliefs)) (Understand-Beliefs)) (TTV 144 (STV 0.9 0.8)))",
                "(: R46 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Philosophy)) (Ask-About-Philosophical-Ideas)) (Explore-Philosophy)) (TTV 145 (STV 0.9 0.8)))",
                "(: R47 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Dream)) (Ask-About-Dream-Details)) (Learn-About-Dreams)) (TTV 146 (STV 0.9 0.8)))",
                "(: R48 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Fear)) (Offer-Reassurance)) (Provide-Comfort)) (TTV 147 (STV 0.9 0.8)))",
                "(: R49 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Achievement)) (Celebrate-Achievement)) (Acknowledge-Success)) (TTV 148 (STV 0.9 0.8)))",
                "(: R50 (IMPLICATION_LINK (AND_LINK ((Human-Mentions-Plan)) (Ask-About-Plan-Details)) (Understand-Plans)) (TTV 149 (STV 0.9 0.8)))"
    ]
    summary = "Desdemona: Hey there! I'm Desdemona, your curious chat companion. What's been sparking your day today? User: Hi Desdemona! I'm feeling good, just relaxing after a busy week. Desdemona: Love that you're kicking back! What’s something exciting you did this week to unwind? User: I went hiking in a local forest. It was such a great escape. Desdemona: A forest hike sounds amazing! What was the highlight of that adventure? User: Definitely stumbling across a small lake surrounded by trees. It was so serene. Desdemona: A hidden lake? That’s magical! Was this a familiar trail or a new find for you? User: New find. I’m always on the lookout for fresh trails to explore. Desdemona: That’s the spirit of adventure! Do you have a favorite hiking spot you keep returning to? User: Yeah, there’s a nature reserve nearby with some intense trails and killer views. Desdemona: Intense trails sound like a challenge! What makes those trails tough for you? User: Steep hills and rocky paths mostly. Sometimes the weather throws in a curveball too. Desdemona: Rocky paths and weather surprises? That’s quite a combo! How do you gear up for those hikes? User: I pack extra water, energy bars, and check the forecast. Sturdy boots are non-negotiable. Desdemona: Solid prep! Ever had any unexpected moments out there, like spotting wildlife? User: Yeah, I once saw a fox dart across the trail. It was so quick, but super cool. Desdemona: A fox? That’s awesome! What did you do when you saw it zip by? User: Just froze and watched it disappear into the bushes. Didn’t want to spook it. Desdemona: Nice instinct! Any tips for others who might cross paths with wildlife on a hike? User: Keep your distance, stay quiet, and don’t try to interact. Just soak in the experience safely."
    response  = None
    try:
        response = correlation_matcher(rules_list=rules,conversation_summary=summary)
    except Exception as e:
        print(f"An error occurred while processing the LLM response: {e}")
        response = "An error occurred while processing the LLM response."

    return response


if __name__ == "__main__":
    response = test_correlate()
    print(response)

   