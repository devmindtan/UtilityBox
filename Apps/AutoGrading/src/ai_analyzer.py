from google import genai
from google.genai import types


class AIAnalyzer:
    def __init__(self, API_KEY, MODEL_NAME):
        self.client = genai.Client(api_key=API_KEY)
        self.model_name = MODEL_NAME

    def genemi_call(self, prompt_text, images):
        response = self.client.models.generate_content(
            model=self.model_name,
            contents=[
                types.Part.from_text(text=prompt_text),
                *images
            ]
        )

        return response.text
