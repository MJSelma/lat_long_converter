import pymongo
from datetime import datetime
from bson.objectid import ObjectId

# MongoDB Configuration
MONGO_URI = "mongodb://localhost:27017/"
DB_NAME = "test_coords"
COLLECTION_NAME = "coords_data"

# Connect to MongoDB
client = pymongo.MongoClient(MONGO_URI)
db = client[DB_NAME]

# Ensure the database and collection exist
collection = db[COLLECTION_NAME]

# Create indexes for latitude and longitude
collection.create_index([("lat", pymongo.ASCENDING)])  # Ensure correct field name
collection.create_index([("lng", pymongo.ASCENDING)])  # Ensure correct field name

# Function to save coordinates in Decimal Degrees format
def save_coords(notes: str, lat_dd: float, lng_dd: float):
    """
    Save coordinates to the database in Decimal Degrees (DD) format.

    :param notes: Notes or description for the coordinate.
    :param lat_dd: Latitude in Decimal Degrees.
    :param lng_dd: Longitude in Decimal Degrees.
    """
    # Ensure the input is in Decimal Degrees format
    if not (-90 <= lat_dd <= 90):
        raise ValueError("Latitude must be between -90 and 90 degrees.")
    if not (-180 <= lng_dd <= 180):
        raise ValueError("Longitude must be between -180 and 180 degrees.")
    
    # Prepare the document
    document = {
        "_id": str(ObjectId()),  # Generate a unique ID
        "notes": notes,
        "lat": lat_dd,  # Use the correct field names for lat and lng
        "lng": lng_dd,  # Use the correct field names for lat and lng
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }
    
    # Insert the document into the collection
    result = collection.insert_one(document)
    print(f"Coordinates saved with ID: {result.inserted_id}")


if __name__ == "__main__":
    # Create the database and collection
    print(f"Database '{DB_NAME}' and collection '{COLLECTION_NAME}' are ready.")

    # Test saving coordinates
    try:
        notes = "Sample coordinate: West Rembo, Makati City"
        lat_dd = 14.554729  # Example latitude in DD
        lng_dd = 121.049845  # Example longitude in DD
        save_coords(notes, lat_dd, lng_dd)
    except ValueError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
