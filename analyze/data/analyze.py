#!/usr/bin/python3
import os, csv, argparse
import pandas as pd
from pdb import set_trace as bp

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
  
          income:   \033[1;32m{income}\033[0m
          expenses: \033[1;31m{expenses}\033[0m
          net:      \033[1;3{('2' if (income > expenses) else '1')}m{income + expenses}\033[0m
  
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


if __name__ == "__main__":
  cli = argparse.ArgumentParser(description="Ingest and analyze Personal Capital aggregated expenses file.")
  cli.add_argument("file", type=str, help="Path to the aggregated expenses file.")
  cli.add_argument("-q", "--quicklook", action="store_true", help="Quicklook analysis of income/expenses")
  cli.add_argument("-c", "--category", action="store_true", help="Categorical analysis of Rent, Travel, Car-Related, and Other expenses based on keywords")
  args = cli.parse_args()
  validate_empowerfile(args.file)
  doall = (0 == 0 + args.quicklook + args.category)
  if doall or args.quicklook:
    quicklook(args.file)
  if doall or args.category:
    category_analysis(args.file)
