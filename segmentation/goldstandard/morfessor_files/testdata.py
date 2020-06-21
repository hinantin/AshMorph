import morfessor

io = morfessor.MorfessorIO()

model = io.read_binary_model_file('model.bin')

f=open("../sentences.pan-ashaninka.test", "r")
Lines = f.readlines() 

for line in Lines: 
  txt = line.strip()
  words = txt.split(" ")
  for word in words:
    pieces = model.viterbi_segment(word)[0]
    print('@@'.join(pieces))
  print("\n")
