import collections

f = open('class.txt')
line = f.readline()

dict = {}
while line:
    line = line.strip()
    if line != '':
        num = int(line)
        if num not in dict:
            dict[num] = 1
        else:
            dict[num] += 1
    line = f.readline()
f.close()
dict = sorted(dict.items(), key=lambda x: x[0])    
print(dict)