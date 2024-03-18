using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneBy : MonoBehaviour
{

    public GameObject HitBox;

    public string nameOfScene;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider HitBox)
    {
        SceneManager.LoadScene(nameOfScene);
    }
}
