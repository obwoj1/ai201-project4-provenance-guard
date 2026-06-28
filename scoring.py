"""Confidence scoring for Provenance Guard.

Combines the two detection signals into a single confidence value and maps that
value onto a human-readable attribution label.
"""


def combine_scores(groq_score, stylo_score):
    """Combine the Groq and stylometric signals into one confidence value.

    Weights the Groq signal at 60% and the stylometric signal at 40%. Returns a
    single float rounded to two decimal places, where higher values indicate the
    text is more likely AI-generated.
    """
    confidence = 0.6 * groq_score + 0.4 * stylo_score
    return round(confidence, 2)


def get_label(confidence):
    """Map a confidence value onto a human-readable attribution label.

    Thresholds:
        confidence >= 0.70 -> "⚠️ Likely AI-Generated"
        0.40 <= confidence <= 0.69 -> "🔍 Uncertain Origin"
        confidence < 0.40 -> "✅ Likely Human-Written"
    """
    if confidence >= 0.70:
        return "⚠️ Likely AI-Generated"
    elif confidence >= 0.40:
        return "🔍 Uncertain Origin"
    else:
        return "✅ Likely Human-Written"
