import pandas as pd 
def most_common(lst):
    return max(set(lst), key=lst.count)

df = pd.read_csv('class_majority.txt', index_col=None, header=None)
print(df)
majority_dict = {}
for index, row in df.iterrows():
    md = most_common(list(row))
    if md in majority_dict:
        majority_dict[md] +=1
    else:
        majority_dict[md] = 1

majority_dict = sorted(majority_dict.items(), key=lambda x: x[0])    
print(majority_dict)