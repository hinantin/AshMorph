import google.generativeai as genai
import os

genai.configure(api_key=os.environ["API_KEY"])

model = genai.GenerativeModel('gemini-1.5-flash-8b')

input1 = input()
response = model.generate_content("from this huge list of meanings, can you get the most likely for each suffix "+input1)
print(response.text) 