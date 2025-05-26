using UnityEngine;

[RequireComponent (typeof(Renderer))]
public class Hologram : MonoBehaviour
{
    [SerializeField] private Color effectColor;
    [SerializeField] private float intervalTime;
    [SerializeField] private float durationTime;
    [SerializeField] [Range(0, 1)] private float amount;

    private MaterialPropertyBlock props;
    private Renderer _renderer;
    private Material _materialInstance;
    private float timer;
    private bool isActive;
    private Color originalColor;

    private void Start()
    {
        _renderer = GetComponent<Renderer>();
        props = new MaterialPropertyBlock();

        _materialInstance = new Material(_renderer.sharedMaterial);
        _renderer.material = _materialInstance;

        originalColor = _materialInstance.GetColor("_TintColor");

        timer = intervalTime;
        isActive = false;
        SetAmount(0f, originalColor);
    }

    private void Update()
    {
        timer -= Time.deltaTime;

        if (timer < 0f)
        {
            if (isActive)
            {
                isActive = false;
                SetAmount(0f, originalColor);
                timer = intervalTime;
            }
            else
            {
                isActive = true;
                SetAmount(amount, effectColor);
                timer = durationTime;
            }
        }
    }

    void SetAmount(float amount, Color color)
    {
        _renderer.GetPropertyBlock(props);
        props.SetFloat("_Amount", amount);
        _renderer.SetPropertyBlock(props);
        _materialInstance.SetColor("_TintColor", color);
    }
}
