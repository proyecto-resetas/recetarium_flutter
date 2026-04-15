import os
import glob
import shutil

moves = {
    'lib/api/get_api_recetas.dart': 'lib/src/core/api/get_api_recetas.dart',
    'lib/config/themes/app_theme.dart': 'lib/src/core/theme/app_theme.dart',
    'lib/config/themes/app_input_style.dart': 'lib/src/core/theme/app_input_style.dart',
    
    'lib/widgets/create_recipe.dart': 'lib/src/features/recipes/ui/create_recipe.dart',
    'lib/widgets/ingredients_utensil.dart': 'lib/src/features/recipes/ui/ingredients_utensil.dart',
    'lib/widgets/add_steps.dart': 'lib/src/features/recipes/ui/add_steps.dart',
    'lib/widgets/book_recipes.dart': 'lib/src/features/recipes/ui/book_recipes.dart',
    'lib/widgets/card_recipe.dart': 'lib/src/features/recipes/ui/card_recipe.dart',
    'lib/widgets/input_dynamic_ingredients.dart': 'lib/src/features/recipes/ui/input_dynamic_ingredients.dart',
    'lib/widgets/input_dynamic_steps.dart': 'lib/src/features/recipes/ui/input_dynamic_steps.dart',
    'lib/widgets/my_recipes_created.dart': 'lib/src/features/recipes/ui/my_recipes_created.dart',
    'lib/widgets/my_recipes_favorite.dart': 'lib/src/features/recipes/ui/my_recipes_favorite.dart',
    'lib/widgets/view_recipes.dart': 'lib/src/features/recipes/ui/view_recipes.dart',
    'lib/widgets/my_purchased_recipes.dart': 'lib/src/features/shopping_cart/ui/my_purchased_recipes.dart',
    'lib/widgets/image_card.dart': 'lib/src/core/widgets/image_card.dart',
    
    'lib/screens/recipes_details.screen.dart': 'lib/src/features/recipes/ui/recipes_details.screen.dart',
    'lib/screens/admin_home_screen.dart': 'lib/src/features/admin/ui/admin_home_screen.dart',
    'lib/screens/login_screen.dart': 'lib/src/features/auth/ui/login_screen.dart',
    'lib/screens/register_screen.dart': 'lib/src/features/auth/ui/register_screen.dart',
    'lib/screens/MyScrollableWidget.dart': 'lib/src/core/widgets/MyScrollableWidget.dart',
    'lib/screens/car_shop.screen.dart': 'lib/src/features/shopping_cart/ui/car_shop.screen.dart',
    'lib/screens/steps_screen.dart': 'lib/src/features/recipes/ui/steps_screen.dart',
    'lib/screens/my_profile_screen.dart': 'lib/src/features/user_profile/ui/my_profile_screen.dart',
    'lib/screens/home_screen.dart': 'lib/src/features/recipes/ui/home_screen.dart',
    
    'lib/models/token_model.dart': 'lib/src/features/auth/models/token_model.dart',
    'lib/models/image_s3_model.dart': 'lib/src/features/recipes/models/image_s3_model.dart',
    'lib/models/user_model.dart': 'lib/src/features/user_profile/models/user_model.dart',
    'lib/models/recipes_model.dart': 'lib/src/features/recipes/models/recipes_model.dart',
    'lib/models/entities/auth_response.dart': 'lib/src/features/auth/models/auth_response.dart',
    'lib/models/entities/user.dart': 'lib/src/features/user_profile/models/user.dart',
    'lib/models/book_recipe_model.dart': 'lib/src/features/recipes/models/book_recipe_model.dart',
    'lib/models/ingredients_model.dart': 'lib/src/features/recipes/models/ingredients_model.dart',
    'lib/models/utensil_model.dart': 'lib/src/features/recipes/models/utensil_model.dart',
    'lib/models/steps_model.dart': 'lib/src/features/recipes/models/steps_model.dart',
    
    'lib/providers/my_recipes_created_provider.dart': 'lib/src/features/recipes/data/my_recipes_created_provider.dart',
    'lib/providers/payment_wompi_provider.dart': 'lib/src/features/shopping_cart/data/payment_wompi_provider.dart',
    'lib/providers/recipes_provider.dart': 'lib/src/features/recipes/data/recipes_provider.dart',
    'lib/providers/car_shop_provider.dart': 'lib/src/features/shopping_cart/data/car_shop_provider.dart',
    'lib/providers/steps_provider.dart': 'lib/src/features/recipes/data/steps_provider.dart',
    'lib/providers/recipes_favorite_provider.dart': 'lib/src/features/recipes/data/recipes_favorite_provider.dart',
    'lib/providers/auth_provider.dart': 'lib/src/features/auth/data/auth_provider.dart',
    
    'lib/app.dart': 'lib/src/app.dart'
}

for k, v in moves.items():
    if os.path.exists(k):
        os.makedirs(os.path.dirname(v), exist_ok=True)
        shutil.move(k, v)

package_name = 'resetas'

import_map = {}
for k, v in moves.items():
    old_import_pkg = f"package:{package_name}/{k[4:]}"
    new_import_pkg = f"package:{package_name}/{v[4:]}"
    import_map[old_import_pkg] = new_import_pkg
    
    import_map[f"'{k[4:]}'"] = f"'{v[4:]}'"
    import_map[f'"{k[4:]}"'] = f'"{v[4:]}"'

dart_files = glob.glob('lib/**/*.dart', recursive=True)
for f in dart_files:
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
            
        original = content
        for old_i, new_i in import_map.items():
            content = content.replace(old_i, new_i)
            
        if original != content:
            with open(f, 'w', encoding='utf-8') as file:
                file.write(content)
    except Exception as e:
        print(f"Error processing {f}: {e}")
