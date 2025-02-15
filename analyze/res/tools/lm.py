#!/usr/bin/python3
"""
Analysis helper functions for linear regression

Workflow:
  - mydf = pandas.read_csv(CSVFILE)
  - print(mydf.describe())
  - model = lm(formula = 'phy_lbr ~ log(tot_emp) + women + white + black + asian + hispanic', data=mydf).fit()
  - lmsummary(model)
  - bptest(model)
"""
import argparse
import pandas
from pdb import set_trace as bp
from numpy import log

# Stats models function naming
import statsmodels.formula.api as smf
import statsmodels.stats.api as sms
from statsmodels.compat import lzip
lm      = smf.ols

BLS_CSV = "./data/bls/bls.csv"

def bptest(olsModelData):
    """
    Python re-implementation of R Breusch Pagan test of homoskedasticity 'bptest()'
    @param olsModelData : linear model resulting from statsmodels.formula.api.ols call
    @return res         : Wrapper instance around statsmodels.stats.api.het_breuschpagan call
    """
    # Define toString value for bptest result
    class Bpresult:
        """
        Wrapper class around statsmodels.stats.api.het_breuschpagan
          .fieldnames: String fieldnames of Breusch Pagan test results
          .bpvalues  : Values corresponding to fieldnames
          .result    : Dictionary of combined fieldnames and values
          __str__()  : Overload ToString method for nice printing
        """
        def __init__(self, olsModelData):
            """
            Initialization of Bpresult wrapper
            @param olsModelData: linear model resulting from statsmodels.formula.api.ols call
            """
            self.olsModelData = olsModelData
            self.fieldnames   = ['Lagrange multiplier statistic', 'p-value', 'f-value', 'p-value']
            self.bpvalues     = sms.het_breuschpagan(olsModelData.resid, olsModelData.model.exog)
            self.result = {}
            for i in range(len(self.fieldnames)):
                key   = self.fieldnames[i]
                value = self.bpvalues[i]
                self.result[key] = value
        def __str__(self):
            """
            Bpresult wrapper __str__ override
            Will print model formula, Lagrange multiplier statistic (BP), df_model value, and p-value
            """
            rep = '\n\t-- studentized Breusch-Pagan test --\n'
            rep += f"formula = {self.olsModelData.model.formula}\n"
            rep += f"BP      = {self.result['Lagrange multiplier statistic']}\n"
            rep += f"df      = {self.olsModelData.df_model}\n"
            if (self.result['p-value'] < (2.2 * (10**-16))):
                rep += f"p-value < 2.2e-16\n"
            else:
                rep += f"p-value = {self.result['p-value']}\n"
            rep +='\n'
            return rep
    res = Bpresult(olsModelData)
    return res

import statsmodels.formula.api as smf
import pandas as pd

def lmsummary(lm):
    """Prints an R-style regression summary with asterisks on the p-value column."""
    
    # Extract coefficients, standard errors, t-values, and p-values
    summary_df = pd.DataFrame({
        'Estimate': lm.params,
        'Std. Error': lm.bse,
        't value': lm.tvalues,
        'Pr(>|t|)': lm.pvalues
    })

    # Function to add significance stars based on p-value
    def significance_stars(p):
        if p < 0.001:
            return '***'
        elif p < 0.01:
            return '**'
        elif p < 0.05:
            return '*'
        elif p < 0.1:
            return '.'
        else:
            return ''

    # Append significance stars to the Pr(>|t|) column
    summary_df['Significance'] = summary_df['Pr(>|t|)'].apply(significance_stars)
    summary_df['Pr(>|t|)'] = summary_df.apply(lambda row: f"{row['Pr(>|t|)']:.4f} {row['Significance']}", axis=1)
    
    # Drop the extra significance column (already appended to p-value)
    summary_df = summary_df.drop(columns=['Significance'])
    
    # Print in a formatted way similar to R
    print("\nCoefficients:")
    print(summary_df.to_string(float_format="%.4f"))

    # Additional model statistics
    print("\nResidual standard error: {:.4f} on {} degrees of freedom".format(
        lm.mse_resid**0.5, lm.df_resid
    ))
    print("Multiple R-squared: {:.4f}, Adjusted R-squared: {:.4f}".format(
        lm.rsquared, lm.rsquared_adj
    ))
    print("F-statistic: {:.2f} on {} and {} DF,  p-value: {:.4g}".format(
        lm.fvalue, lm.df_model, lm.df_resid, lm.f_pvalue
    ))

if __name__ == "__main__":
  cli = argparse.ArgumentParser(description="Do a linear regression on a csv file")
  cli.add_argument("-f", "--file", type=str, help="Path to the CSV file to be analyzed.")
  cli.add_argument("-m", "--model", type=str, help="Model you'd like to test ie: 'y ~ log(x1) + x2 + x3'.")
  args = cli.parse_args()

  df = pandas.read_csv(args.file)
  print(df.describe())
  if(args.model):
    model = lm(formula = args.model).fit()
    lmsummary(model)
