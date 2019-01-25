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
    condition = data_df['town'] == town
    numbers = len(data_df[condition]['price'])
    max_id = data_df[condition]['price'].idxmax()
    min_id = data_df[condition]['price'].idxmin()
    max_value = int(data_df.loc[max_id, 'price'])
    min_value = int(data_df.loc[min_id, 'price'])
    price_sum = int(data_df[condition]['price'].sum(axis=0))
    average_price = int(price_sum / numbers)
    entries.append(numbers)
    entry_max_price.append(max_value)
    entry_min_price.append(min_value)
    entry_average_price.append(average_price)

data = {'town':towns, 'entries':entries, 'max_price':entry_max_price, 'min_price':entry_min_price, 'average_price': entry_average_price}
columns = ['town', 'entries', 'max_price', 'min_price', 'average_price']
new_data = pd.DataFrame(data,columns=columns)
new_data.sort_values(by='average_price',ascending=False, inplace=True)
new_data.to_csv("q2.csv", index=False, header=0)

    
