using UnityEngine;

public class AudioPlayer : MonoBehaviour
{
    public AudioSource audioSource; // Reference to the AudioSource component
    public AudioClip audioClip; // Reference to the AudioClip

    private bool hasPlayed; // Flag to track if the audio has been played

    private void Start()
    {
        if (audioClip != null)
        {
            // Preload the audio clip data to reduce delay when playing
            audioClip.LoadAudioData();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") && !hasPlayed) // Check if the collider belongs to the player and audio hasn't been played yet
        {
            // Check if the audio source is assigned
            if (audioSource != null && audioClip != null)
            {
                // Assign the audio clip to the AudioSource
                audioSource.clip = audioClip;

                // Play the audio source
                audioSource.Play();

                hasPlayed = true; // Set the flag to true to indicate that the audio has been played
            }
            else
            {
                Debug.LogWarning("AudioSource or AudioClip is not assigned.");
            }
        }
    }
}
