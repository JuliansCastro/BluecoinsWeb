#!/usr/bin/env python3
"""
Test script to verify locale handling works correctly
"""
import locale

def set_spanish_locale():
    """
    Try to set Spanish locale for month names, fallback to default if not available.
    """
    spanish_locales = [
        'es_ES.UTF-8',      # Linux/Mac
        'es_ES',            # Linux/Mac alternative
        'Spanish_Spain.1252', # Windows
        'Spanish',          # Windows alternative
        'esp',              # Some systems
    ]
    
    for locale_name in spanish_locales:
        try:
            locale.setlocale(locale.LC_TIME, locale_name)
            print(f"Successfully set locale to: {locale_name}")
            return locale_name
        except locale.Error:
            continue
    
    # If no Spanish locale is available, keep the default
    print("Warning: No Spanish locale available, using system default")
    return None

if __name__ == "__main__":
    print("Testing locale handling...")
    print(f"Current locale: {locale.getlocale()}")
    
    result = set_spanish_locale()
    
    if result:
        print(f"Spanish locale set successfully: {result}")
    else:
        print("No Spanish locale available, using default")
    
    print(f"Final locale: {locale.getlocale()}")
    print("Test completed successfully - no errors!")
