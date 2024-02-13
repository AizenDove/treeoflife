using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;

namespace RealFireSmoke
{


public class RealFireSceneSelect : MonoBehaviour
{
	public bool GUIHide = false;
	
	public void Scene01_ALT()			{ SceneManager.LoadScene("Scene01_ALT");		}
	public void Scene02_ALT()			{ SceneManager.LoadScene("Scene02_ALT"); 		}
	public void Scene03_ALT()			{ SceneManager.LoadScene("Scene03_ALT"); 		}
	public void Scene04_ALT()			{ SceneManager.LoadScene("Scene04_ALT"); 		}
	public void Scene05_ALT()			{ SceneManager.LoadScene("Scene05_ALT");	 	}
	
	public void Scene01_HR()			{ SceneManager.LoadScene("Scene01_HR");			}
	public void Scene02_HR()			{ SceneManager.LoadScene("Scene02_HR"); 		}
	public void Scene03_HR()			{ SceneManager.LoadScene("Scene03_HR"); 		}
	public void Scene04_HR()			{ SceneManager.LoadScene("Scene04_HR"); 		}
	public void Scene05_HR()			{ SceneManager.LoadScene("Scene05_HR");	 		}
	
	public void Scene01_LR()			{ SceneManager.LoadScene("Scene01_LR");			}
	public void Scene02_LR()			{ SceneManager.LoadScene("Scene02_LR"); 		}
	public void Scene03_LR()			{ SceneManager.LoadScene("Scene03_LR"); 		}
	public void Scene04_LR()			{ SceneManager.LoadScene("Scene04_LR"); 		}
	public void Scene05_LR()			{ SceneManager.LoadScene("Scene05_LR");	 		}
	
	public void StyleComparison()		{ SceneManager.LoadScene("StyleComparison");	}


void Update ()
{
     if(Input.GetKeyDown(KeyCode.L))
	 {
         GUIHide = !GUIHide;
     
         if (GUIHide)
		 {
             GameObject.Find("CanvasSceneSelect").GetComponent<Canvas> ().enabled = false;
         }
		 
		 else
		 {
             GameObject.Find("CanvasSceneSelect").GetComponent<Canvas> ().enabled = true;
         }
     }
}

}

}