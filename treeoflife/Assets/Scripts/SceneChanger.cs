using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneChanger : MonoBehaviour
{
    public string sceneToLoad; // Name of the scene to load

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player")) // Check if the collider belongs to the player
        {
            ChangeScene(); // Call the method to change the scene
        }
    }

    private void ChangeScene()
    {
        SceneManager.LoadScene(sceneToLoad); // Load the specified scene
    }
}
