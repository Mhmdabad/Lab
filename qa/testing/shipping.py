def calculate_shipping(basket_total, is_member=False):
    # Bug Fix: Guard clause to reject negative totals
    if basket_total < 0:
        raise ValueError("Basket total cannot be negative.")
        
    if basket_total >= 50 or is_member:
        return 0.0
    if basket_total >= 20:
        return 2.99
    return 4.99