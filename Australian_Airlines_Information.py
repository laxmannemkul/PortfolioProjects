import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Sample Airline Data
airline_data = [
    {"Airline": "Air Link", "IATA": "LZ", "ICAO": "-", "Hub": "-", "Airport": "Dubbo City Regional Airport", "Notes": "Ceased passenger services January 2018. Recommenced in November 2019."},
    {"Airline": "Airnorth", "IATA": "TL", "ICAO": "ANO", "Hub": "TOPEND", "Airport": "Darwin International Airport", "Notes": "Operates scheduled services to regional airports in Queensland, Western Australia, and the Northern Territory. Also has an international service to Timor Leste."},
    {"Airline": "Alliance Airlines", "IATA": "QQ", "ICAO": "UTY", "Hub": "UNITY", "Airport": "Brisbane Airport", "Notes": "Owns and operates a fleet of Fokker aircraft including Fokker 70 and Fokker 100 jet aircraft. Operates Virgin Australia branded flights, as well as closed charter and FIFO for mining operations around Australia. They have also wet-leased several Embraer 190s to Qantas since June 2021."},
    {"Airline": "Aviair", "IATA": "GD", "ICAO": "-", "Hub": "-", "Airport": "East Kimberley Regional Airport", "Notes": "Previously known as Slingair Heliworks."},
    {"Airline": "Bonza", "IATA": "AB", "ICAO": "BNZ", "Hub": "BONZA", "Airport": "Sunshine Coast Airport", "Notes": ""},
    {"Airline": "Chartair", "IATA": "-", "ICAO": "-", "Hub": "-", "Airport": "Darwin International Airport", "Notes": ""},
    {"Airline": "Eastern Air Services", "IATA": "-", "ICAO": "-", "Hub": "-", "Airport": "Port Macquarie Airport", "Notes": "Based in Port Macquarie with RPT between Lord Howe Island and Port Macquarie, Newcastle, and Gold Coast."},
    {"Airline": "Eastern Australia Airlines", "IATA": "QF", "ICAO": "QLK", "Hub": "Q-LINK", "Airport": "Sydney Airport", "Notes": "Operates Bombardier Q200 and Q300 aircraft under the QantasLink brand."},
    {"Airline": "FlyPelican", "IATA": "FP", "ICAO": "FRE", "Hub": "PELICAN", "Airport": "Newcastle Airport", "Notes": "Regional airline operating in NSW, ACT, and Queensland with a fleet of 5 Jetstream 32 aircraft."},
    {"Airline": "Fly Tiwi", "IATA": "FT", "ICAO": "-", "Hub": "-", "Airport": "Darwin International Airport", "Notes": "Owned by Hardy Aviation."},
]

# Create DataFrame
airline_df = pd.DataFrame(airline_data)

# Task 1: Sort Airlines by Type
airline_types = airline_df.groupby('Notes').size().sort_values(ascending=False)
most_used_type = airline_types.idxmax()
least_used_type = airline_types.idxmin()

# Task 2: Find the Most and Least Used Airlines
most_used_airlines = airline_df.loc[airline_df['Notes'] == most_used_type]
least_used_airlines = airline_df.loc[airline_df['Notes'] == least_used_type]

# Task 3: Find the Highest Fare and Traveler to Flight Ratio
highest_fare_airlines = airline_df.loc[airline_df['Notes'].str.contains('highest fare', case=False)]
traveler_flight_ratio_airlines = airline_df.loc[airline_df['Notes'].str.contains('treveller to flight ratio', case=False)]

# Task 4: Calculate Average Delay
# Assuming a column 'AverageDelay' is available in the DataFrame
airline_df['AverageDelay'] = [10, 5, 15]  # Replace with actual delay data
average_delay = airline_df['AverageDelay'].mean()

# Charts
plt.figure(figsize=(15, 5))

# Task 1: Bar Chart for Airlines Sorted by Type
plt.subplot(2, 2, 1)
airline_types.plot(kind='bar', color='skyblue')
plt.title("Airlines Sorted by Type")
plt.xlabel("Type")
plt.ylabel("Count")

# Task 2: Bar Chart for Most and Least Used Airlines
plt.subplot(2, 2, 2)
sns.countplot(x='Airline', data=most_used_airlines, palette='viridis')
plt.title("Most Used Airlines")

plt.subplot(2, 2, 3)
sns.countplot(x='Airline', data=least_used_airlines, palette='viridis')
plt.title("Least Used Airlines")

# Task 3: Bar Chart for Highest Fare and Traveler to Flight Ratio Airlines
plt.subplot(2, 2, 4)
sns.barplot(x='Airline', y='IATA', data=highest_fare_airlines, palette='muted')
plt.title("Highest Fare Airlines")

plt.tight_layout()
plt.show()

# Task 4: Histogram for Average Delay Across Airlines
plt.figure(figsize=(8, 5))
sns.histplot(airline_df['AverageDelay'], bins=20, kde=True, color='orange')
plt.title("Histogram of Average Delay Across Airlines")
plt.xlabel("Average Delay (minutes)")
plt.ylabel("Frequency")
plt.show()
