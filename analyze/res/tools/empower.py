#!/usr/bin/python3
import os, csv, argparse
import pandas as pd
import matplotlib.pyplot as plt
from pdb import set_trace as bp

def colorize(value):
    return(f"\033[1;3{('2' if (value>0) else '1')}m{value}\033[0m")

def validate_empowerfile(file_path):
  # Check if file exists
  if not os.path.isfile(file_path):
    raise FileNotFoundError(f"The file '{file_path}' does not exist.")

  # Check if file is a CSV
  if not file_path.endswith('.csv'):
    raise ValueError(f"The file '{file_path}' is not a CSV file.")

  # Define expected header
  expected_header = ["Date", "Account", "Description", "Category", "Tags", "Amount"]

  with open(file_path, newline='', encoding='utf-8') as csvfile:
    reader = csv.reader(csvfile)
    header = next(reader, None)

    # Check if header matches expected format
    if header != expected_header:
      raise ValueError(f"Empower expenses CSV header mismatch. Expected: {expected_header}, Found: {header}")

    # Validate each row
    for row in reader:
      if len(row) != len(expected_header):
        raise ValueError(f"Row has an incorrect number of columns: {row}")

      # Check column formats
      try:
        # Check date format (YYYY-MM-DD)
        from datetime import datetime
        datetime.strptime(row[0], '%Y-%m-%d')

        # Check amount is a float
        float(row[5])
      except ValueError as e:
        raise ValueError(f"Invalid data in row: {row}. Error: {e}")

def quicklook(filepath):
  income = expenses = 0
  data = pd.read_csv(filepath)

  for a in data["Amount"]:
      if a > 0:
          income += a
      else:
          expenses += a
  print(f"""
  From 2022-07-29 to 2024-12-31:
  
          income:   {colorize(income)}
          expenses: {colorize(expenses)}
          net:      {colorize(income + expenses)}
  
  """)

def category_analysis(filepath):
  """
  Fixed expenses: Rent, Utilities(electric, water), Insurance(car, renters), Phone, Vehichle (gas, oil, repairs), Groceries
  Variable: Restaurants, Coffee, Entertainment, Amazon
  """
  data = pd.read_csv(filepath)
  data["Amount"] = pd.to_numeric(data["Amount"], errors='coerce')
  data = data[data["Amount"] < 0]
  
  categories_mapping = {
      "Rent": ["Rent", "Utilities", "Electric", "Water", "HOA", "Trash", "Internet", "Cable"],
      "Groceries":["Groceries", "Supermarket", "Farm"],
      "Car Related Expenses": ["Gas", "Fuel", "Tires", "Oil", "Car", "Insurance", "Auto", "Repairs", "Maintenance", "Vehichle"],
      "Recreational": ["Airfare", "Hotels", "Travel", "Flight", "Vacation", "Lodging", "Ski", "Mountain", "Restaurant", "Park"],
      "Merchandise": [
          "Clothing", "Technology", "General Merchandise", "Electronics",
          "Gadgets", "Apparel", "Shoes", "Accessories", "Furniture", "Home Goods",
          "Books", "Toys", "Gifts", "Sports Equipment", "Jewelry", "Cosmetics",
          "Personal Care", "Beauty", "Tools", "Hardware", "Office Supplies"
      ],
      "Other": []  # Placeholder for unclassified expenses
  }
  
  # Initialize totals for each category
  category_totals = {key: 0 for key in categories_mapping.keys()}
  
  # Calculate totals for each category
  for category, keywords in categories_mapping.items():
      if keywords:
          # Create a mask to filter rows containing keywords in either Category or Description
          mask = (
              data["Category"].str.contains('|'.join(keywords), na=False, case=False) |
              data["Description"].str.contains('|'.join(keywords), na=False, case=False)
          )
          category_totals[category] = data.loc[mask, "Amount"].sum()
      else:
          # For "Other", include expenses not matched in any other category
          all_keywords = '|'.join([kw for kws in categories_mapping.values() for kw in kws])
          mask = ~(
              data["Category"].str.contains(all_keywords, na=False, case=False) |
              data["Description"].str.contains(all_keywords, na=False, case=False)
          )
          category_totals[category] = data.loc[mask, "Amount"].sum()
  
  # Convert the results into a DataFrame for readability
  totals_table = pd.DataFrame(category_totals.items(), columns=["Category", "Amount"])
  
  # Print the results
  print(totals_table.sort_values(by="Amount"))

def simplify_category(df):
  category_mapping = {
    # Personal Saving
    "Deposits":"Saving",
    "Interest":"Saving",
    "Refunds & Reimbursements":"Saving",
    "Other Income":"Saving",

    # Personal Current Taxes
    "Taxes":"Taxes",

    # Health
    "Healthcare/Medical":"Healthcare",
    "Child/Dependent":"Healthcare",
    "Insurance":"Healthcare",

    # Housing, Utilities, and fuels
    "Automotive":"Housing",
    "Cable/Satellite":"Housing",
    "Checks":"Housing",
    "Dues & Subscriptions":"Housing",
    "Gasoline/Fuel":"Housing",
    "Home Improvement":"Housing",
    "Rent":"Housing",
    "Utilities":"Housing",
    "Online Services"

    # Food
    "Groceries":"Food",
    "Restaurants":"Food",
    "ATM/Cash":"Food",

    # Recreational goods & vehichles + recreation services
    "Entertainment":"Recreational",
    "Hobbies":"Recreational",
    "Personal Care":"Recreational",
    "Travel":"Recreational",
    "Women":"Recreational",
    "Gifts":"Recreational",
    "Electronics":"Recreational",
    "Charitable Giving":"Recreational",

    # Other
    "Clothing/Shoes":"Other",
    "Education":"Other",
    "General Merchandise":"Other",
    "Inc Boston Ma":"Other",
    "Ma Xxx-xxx-2500 Nc":"Other",
    "Office Supplies":"Other",
    "Other Expenses":"Other",
    "Postage & Shipping":"Other",
    "Printing":"Other",
    "Service Charges/Fees":"Other"
  }
  df["Category"] = df["Category"].map(category_mapping).fillna("Other")
  return df

def category_plot(filepath):
  df = pd.read_csv(filepath, parse_dates=["Date"])
  df["Amount"] = pd.to_numeric(df["Amount"], errors='coerce')
  df = df[df["Amount"] < 0]

  df = simplify_category(df)

  df["Month"] = df["Date"].dt.to_period("M")
  monthly_spending = df.groupby(["Month", "Category"])['Amount'].sum().unstack(fill_value=0)
  total_spending_per_month = monthly_spending.sum(axis=1)
  spending_percentage = (monthly_spending.T / total_spending_per_month).T * 100
  plt.figure(figsize=(12, 6))
  for category in spending_percentage.columns:
    plt.plot(spending_percentage.index.astype(str), spending_percentage[category], label=category)

  plt.figure(figsize=(12, 6))
  category_colors = {
    "Saving": "green",
    "Taxes": "red",
    "Healthcare": "orange",
    "Housing": "blue",
    "Food": "brown",
    "Recreational": "pink",
    "Other": "yellow"
  }
  for category in spending_percentage.columns:
    color = category_colors.get(category, "gray")  # Default to gray if category not found
    plt.plot(spending_percentage.index.astype(str), spending_percentage[category], label=category, color=color)

  plt.xlabel("Month")
  plt.ylabel("Percentage of Total Spending")
  plt.title("Monthly Spending Breakdown by Category")
  plt.legend(loc="upper right", bbox_to_anchor=(1.3, 1), title="Categories")
  plt.xticks(rotation=45)
  plt.grid()
  #plt.show()
  plt.savefig("spending_breakdown.png")

if __name__ == "__main__":
  cli = argparse.ArgumentParser(description="Ingest and analyze Personal Capital aggregated expenses file.")
  cli.add_argument("file", type=str, help="Path to the aggregated expenses file.")
  cli.add_argument("-q", "--quicklook", action="store_true", help="Quicklook analysis of income/expenses")
  cli.add_argument("-c", "--category", action="store_true", help="Categorical analysis of Rent, Travel, Car-Related, and Other expenses based on keywords")
  cli.add_argument("-p", "--plot", action="store_true", help="Analyze spending categories on a line plot")
  args = cli.parse_args()
  validate_empowerfile(args.file)
  doall = (0 == 0 + args.quicklook + args.category)
  if doall or args.quicklook:
    quicklook(args.file)
  if doall or args.category:
    category_analysis(args.file)
  if args.plot:
    category_plot(args.file)
