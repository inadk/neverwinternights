// Function is placed in the T1_HeartBeat(). Every 6 seconds it extracts the tags of enemies that are located in the altar
void T1_HeartBeat()
{
    if (IsMaster())
    {
        // Get the object for the altar
        object oAltar = GetObjectByTag("WP_CENTRE_BLUE"); //can be any other waypoint

        // Get the first object in the area
        object oCreature = GetFirstObjectInArea(GetArea(oAltar));

        // Initialize a counter for enemies at the altar
        int iEnemiesAtAltar = 0;

        // Loop through all objects in the area
        while (GetIsObjectValid(oCreature))
        {
            // Check if the object is an enemy
            if (GetIsEnemy(oCreature))
            {
                // Check if the enemy is at the altar
                if (GetDistanceBetween(oCreature, oAltar) < 5.0)
                {
                    // Increment the counter
                    iEnemiesAtAltar++;

                    // Print the tag of the enemy
                    SpeakString("Enemy at altar: " + GetTag(oCreature), TALKVOLUME_SHOUT);
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
    }
