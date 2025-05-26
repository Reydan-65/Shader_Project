using UnityEngine;

public class ChangeColorPropBlock : MonoBehaviour
{
    [SerializeField] private Renderer _renderer;
    [SerializeField] private string _name;
    [SerializeField] private Color _color;
    [SerializeField] private float _offset;

    private void Update()
    {
        MaterialPropertyBlock props = new MaterialPropertyBlock();
        props.SetColor(_name, _color );
        props.SetFloat("_Offset", _offset);
        _renderer.SetPropertyBlock(props);
    }
}
