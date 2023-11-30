// Function is placed in the T1_HeartBeat(). Every 6 seconds it displays the number of the enemies and their tags, that are located in the altar

void T1_HeartBeat()
{
    if (IsMaster())
    {
        // Get the object (unit) for the altar
        object oAltar = GetObjectByTag("WP_ALTAR_BLUE_1");

        // Get the first object in the area
        object oCreature = GetFirstObjectInArea(GetArea(oAltar));

        // Initialize a counter for enemies at the altar
        int iEnemiesAtAltar = 0;

        // Initialize a string to store the tags of the enemies
        string sEnemyTags = "";

        // Loop through all objects in the area
        while (GetIsObjectValid(oCreature))
        {
            // Check if the object is an enemy
            if (GetIsEnemy(oCreature))
            {
                // Check if the enemy is at the altar
                if (GetDistanceBetween(oCreature, oAltar) < 10.0)
                {
                    // Increment the counter
                    iEnemiesAtAltar++;

                    // Add the tag of the enemy to the string
                    sEnemyTags += GetTag(oCreature) + ", ";
                }
            }

            // Get the next object in the area
            oCreature = GetNextObjectInArea(GetArea(oAltar));
        }

        // Check if there were any enemies at the altar
        if (iEnemiesAtAltar == 0)
        {
            SpeakString("No enemies at the altar.", TALKVOLUME_SHOUT);
        }
        else
        {
            // Print the number of enemies and their tags
            SpeakString(IntToString(iEnemiesAtAltar) + " enemies at the altar: " + sEnemyTags, TALKVOLUME_SHOUT);
        }
    }
