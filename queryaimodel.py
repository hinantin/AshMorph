import google.generativeai as genai
import os

genai.configure(api_key=os.environ["API_KEY"])

model = genai.GenerativeModel('gemini-1.5-pro')

input1 = input()
response = model.generate_content("from this huge list of meaning, can any of this be interpreted as \"doctor or to cure\""+input1)
print(response.text) 