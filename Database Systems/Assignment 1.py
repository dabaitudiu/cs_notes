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

for town in towns:
    # select town data
    rows = data_df[data_df['town'] == town]
    # compute their price per square meter
    rows_df = rows['price'] / rows['floor_area']
    # records of trade
    numbers = len(rows)
    # max pms
    max_value =  int(round(rows_df.max() + 0.5))
    # min pms
    min_value = int(round(rows_df.min() + 0.5))
    # sum of pms
    price_sum =rows_df.sum(axis=0) 
    # average pms
    average_price =  int(round(price_sum / numbers + 0.5))
    # put data into arrays
    entries.append(numbers)
    entry_max_price.append(max_value)
    entry_min_price.append(min_value)
    entry_average_price.append(average_price)
    # print(town," ", numbers, " ", max_value, " ", min_value, " ", average_price)

data = {'town':towns, 'entries':entries, 'max_price':entry_max_price, 'average_price': entry_average_price, 'min_price':entry_min_price}
columns = ['town', 'entries', 'max_price', 'average_price', 'min_price']
new_data = pd.DataFrame(data,columns=columns)
new_data.sort_values(by='average_price',ascending=False, inplace=True)
new_data.to_csv("q2.csv", index=False, header=0)

# ---------------------------------------------------------------------
# Question 3
# ---------------------------------------------------------------------
    
