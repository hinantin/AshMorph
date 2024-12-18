import google.generativeai as genai
import os
import sys

genai.configure(api_key=os.environ["API_KEY"])

model = genai.GenerativeModel('gemini-1.5-pro')
word = sys.argv[1]
input1 = input()
response = model.generate_content("from this huge list of meanings, can any of this be interpreted as or is related to \"{}\"".format(word)+input1)
print(response.text) 