import requests

def validate_products():
    try:
        # Make GET request to the API
        response = requests.get('https://fakestoreapi.com/products')
        
        # Verify response code
        if response.status_code != 200:
            print(f"Unexpected status code: {response.status_code}")
            return

        products = response.json()
        defective_products = []

        # Validate each product
        for product in products:
            defects = []
            
            # Check for empty title
            if not product.get('title') or not product['title'].strip():
                defects.append('Empty title')

            # Check for negative price
            if product.get('price', 0) < 0:
                defects.append('Negative price')

            # Check for invalid rating
            if product.get('rating', {}).get('rate', 0) > 5:
                defects.append('Rating exceeds 5')

            # If any defects found, add to defective products list
            if defects:
                defective_products.append({
                    'id': product.get('id'),
                    'title': product.get('title'),
                    'defects': defects
                })

        # Print results
        print('Validation Results:')
        print(f'Total products checked: {len(products)}')
        print(f'Defective products found: {len(defective_products)}')
        
        if defective_products:
            print('\nDefective Products:')
            for product in defective_products:
                print(f'\nProduct ID: {product["id"]}')
                print(f'Title: {product["title"]}')
                print('Defects:')
                for defect in product['defects']:
                    print(f'- {defect}')

    except Exception as error:
        print(f'Error during validation: {str(error)}')

# Execute the validation
if __name__ == '__main__':
    validate_products()




