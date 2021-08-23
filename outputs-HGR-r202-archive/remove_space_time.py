text_file = open("sample.txt", "w")
with open('/Users/wanxinli/Desktop/project.nosync/MLDSP/outputs-HGR-r202/train_time.txt') as f:
    output = "".join(line for line in f if not line.isspace())
text_file.write(output)