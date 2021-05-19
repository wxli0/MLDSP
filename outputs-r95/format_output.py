file = open('tmp.txt', 'r')
lines = file.readlines()
total_count = {}
for line in lines:
    key1_index = line.find(',')
    key1 = int(line[:key1_index][1:])
    key2_end_index = line.find(')')
    key2 = int(line[(key1_index+1):key2_end_index])
    val = int(line[line.find(':')+1:])
    if (key1, key2) in total_count:
        total_count[(key1, key2)].append(val)
    else:
        total_count[(key1, key2)] = [val]

total_count = dict(sorted(total_count.items()))

print(total_count)