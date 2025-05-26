using UnityEngine;

public class ChangeColor : MonoBehaviour
{
    [SerializeField] private Renderer _renderer;

    private void Update()
    {
        _renderer.material.SetColor("_BaseColor", Color.red);
    }
}
