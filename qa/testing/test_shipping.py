import pytest
from shipping import calculate_shipping

def test_small_basket_pays_full_shipping():
    assert calculate_shipping(10.00) == 4.99

def test_member_always_ships_free():
    assert calculate_shipping(5.00, is_member=True) == 0.0

# Stage 3: The Boundaries
@pytest.mark.parametrize("total, expected", [
    (19.99, 4.99), # Just under the 20 boundary
    (20.00, 2.99), # Exactly on it
    (49.99, 2.99), # Just under 50
    (50.00, 0.0),  # Exactly on it
])
def test_shipping_boundaries(total, expected):
    assert calculate_shipping(total) == expected

def test_negative_total_is_rejected():
    # Asserting that a ValueError is raised
    with pytest.raises(ValueError):
        calculate_shipping(-5)