using UnityEngine;
using UnityEngine.Rendering;

namespace Kino.Aqua.Universal {

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public sealed class AquaEffect : MonoBehaviour
{
    #region Effect parameters

    [SerializeField, Range(0, 1)] float _opacity = 1;
    [Space]
    [SerializeField] Color _edgeColor = Color.black;
    [SerializeField, Range(0.01f, 4)] float _edgeContrast = 1.2f;
    [Space]
    [SerializeField] Color _fillColor = Color.white;
    [SerializeField, Range(0, 2)] float _blurWidth = 1;
    [SerializeField, Range(0, 1)] float _blurFrequency = 0.5f;
    [SerializeField, Range(0, 0.3f)] float _hueShift = 0.1f;
    [Space]
    [SerializeField, Range(0.1f, 5)] float _interval = 1;
    [SerializeField, Range(4, 32)] int _iteration = 20;

    #endregion

    #region Project asset reference

    [SerializeField, HideInInspector] Shader _shader = null;

    #endregion

    #region Public property

    public Material BlitMaterial => _material;

    #endregion

    #region Private members

    Material _material;

    #endregion

    #region MonoBehaviour implementation

    void OnDestroy()
      => CoreUtils.Destroy(_material);

    void LateUpdate()
    {
        if (_material == null)
            _material = CoreUtils.CreateEngineMaterial(_shader);

        ShaderHelper.SetProperties
          (_material, null,
           opacity: _opacity,
           edgeColor: _edgeColor,
           edgeContrast: _edgeContrast,
           fillColor: _fillColor,
           blurWidth: _blurWidth,
           blurFrequency: _blurFrequency,
           hueShift: _hueShift,
           interval: _interval,
           iteration: _iteration);
    }

    #endregion
}

} // namespace Kino.Aqua.Universal
