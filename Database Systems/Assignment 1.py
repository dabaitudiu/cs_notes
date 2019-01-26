import pandas as pd 
import numpy as np

save_path = "resale-flat-prices.csv"

data_df = pd.read_csv(save_path, header=0, names=['resale_month', 'town', 'flat_type', 'block_number', 
'street_name', 'storey_range', 'floor_area', 'flat_model', 'date', 'price'])

# ---------------------------------------------------------------------
# Question 1
# ---------------------------------------------------------------------

condition1 = data_df['flat_model'] == 'ADJOINED FLAT'
condition2 = data_df['flat_type'] == '3 ROOM'
condition3 = condition1 & condition2 

new_df = data_df[condition3]
# new_df.to_csv("q1.csv", index=False, header=0)

# ---------------------------------------------------------------------
# Question 2
# ---------------------------------------------------------------------
towns = np.unique(data_df['town'])
entries = []
entry_max_price = []
entry_min_price = []
entry_average_price = []

# for town in towns:
#     # select town data
#     rows = data_df[data_df['town'] == town]
#     # compute their price per square meter
#     rows_df = rows['price'] / rows['floor_area']
#     # records of trade
#     numbers = len(rows)
#     # max pms
#     max_value =  int(round(rows_df.max() + 0.5))
#     # min pms
#     min_value = int(round(rows_df.min() + 0.5))
#     # sum of pms
#     price_sum =rows_df.sum(axis=0) 
#     # average pms
#     average_price =  int(round(price_sum / numbers + 0.5))
#     # put data into arrays
#     entries.append(numbers)
#     entry_max_price.append(max_value)
#     entry_min_price.append(min_value)
#     entry_average_price.append(average_price)
#     # print(town," ", numbers, " ", max_value, " ", min_value, " ", average_price)

# data = {'town':towns, 'entries':entries, 'max_price':entry_max_price, 'average_price': entry_average_price, 'min_price':entry_min_price}
# columns = ['town', 'entries', 'max_price', 'average_price', 'min_price']
# new_data = pd.DataFrame(data,columns=columns)
# new_data.sort_values(by='average_price',ascending=False, inplace=True)
# new_data.to_csv("q2.csv", index=False, header=0)

# ---------------------------------------------------------------------
# Question 3
# ---------------------------------------------------------------------
town_name = 'BISHAN'
entries = data_df[data_df['town'] == town_name]
thrid_df = 0
for i in range(len(entries)):
    if i % 300 == 0:
        print(i)
    entry = entries.iloc[[i]]
    price = float(entry['price'])
    area = float(entry['floor_area'])
    condition1 = (entries['price'] > price) & (entries['floor_area'] < area)
    condition2 = (entries['price'] == price) & (entries['floor_area'] < area)
    condition3 = (entries['price'] > price) & (entries['floor_area'] == area)
    condition = condition1 | condition2 | condition3
    results = len(entries[condition])
    # print(results)
    if (results == 0):
        print("HEY")
        if thrid_df == 0:
            third_df = entry 
        else:
            new_third_df = pd.concat(third_df, entry)
            third_df = new_third_df
            print("wtf???")

print(third_df)