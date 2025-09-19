from indic_transliteration import sanscript
from indic_transliteration.sanscript import transliterate

# Map supported scripts
SCRIPT_MAP = {
    "Devanagari": sanscript.DEVANAGARI,
    "Telugu": sanscript.TELUGU,
    "Tamil": sanscript.TAMIL,
    "Malayalam": sanscript.MALAYALAM,
    "Gurmukhi": sanscript.GURMUKHI
}

def convert_text(text: str, target_script: str):
    if target_script not in SCRIPT_MAP:
        return f"Target script {target_script} not supported"
    return transliterate(text, sanscript.DEVANAGARI, SCRIPT_MAP[target_script])
