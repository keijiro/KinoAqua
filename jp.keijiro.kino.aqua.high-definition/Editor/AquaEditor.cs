using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace Kino.PostProcessing {

[VolumeComponentEditor(typeof(Aqua))]
sealed class AquaEditor : VolumeComponentEditor
{
    SerializedDataParameter _opacity;
    SerializedDataParameter _edgeColor;
    SerializedDataParameter _edgeContrast;
    SerializedDataParameter _fillColor;
    SerializedDataParameter _blurWidth;
    SerializedDataParameter _blurFrequency;
    SerializedDataParameter _hueShift;
    SerializedDataParameter _interval;
    SerializedDataParameter _iteration;
    SerializedDataParameter _overlayMode;
    SerializedDataParameter _overlayTexture;
    SerializedDataParameter _overlayOpacity;

    static class Labels
    {
        public static GUIContent Opacity = new GUIContent("Opacity");
        public static GUIContent Texture = new GUIContent("Texture");
    }

    public override void OnEnable()
    {
        var o = new PropertyFetcher<Aqua>(serializedObject);

        _opacity        = Unpack(o.Find(x => x.opacity       ));
        _edgeColor      = Unpack(o.Find(x => x.edgeColor     ));
        _edgeContrast   = Unpack(o.Find(x => x.edgeContrast  ));
        _fillColor      = Unpack(o.Find(x => x.fillColor     ));
        _blurWidth      = Unpack(o.Find(x => x.blurWidth     ));
        _blurFrequency  = Unpack(o.Find(x => x.blurFrequency ));
        _hueShift       = Unpack(o.Find(x => x.hueShift      ));
        _interval       = Unpack(o.Find(x => x.interval      ));
        _iteration      = Unpack(o.Find(x => x.iteration     ));
        _overlayMode    = Unpack(o.Find(x => x.overlayMode   ));
        _overlayTexture = Unpack(o.Find(x => x.overlayTexture));
        _overlayOpacity = Unpack(o.Find(x => x.overlayOpacity));
    }

    public override void OnInspectorGUI()
    {
        PropertyField(_opacity);

        EditorGUILayout.Space();

        PropertyField(_edgeColor);
        PropertyField(_edgeContrast);

        EditorGUILayout.Space();

        PropertyField(_fillColor);
        PropertyField(_blurWidth);
        PropertyField(_blurFrequency);
        PropertyField(_hueShift);

        EditorGUILayout.Space();

        PropertyField(_interval);
        PropertyField(_iteration);

        EditorGUILayout.Space();

        PropertyField(_overlayMode);

        if (_overlayMode.value.hasMultipleDifferentValues ||
            _overlayMode.value.enumValueIndex != 0)
        {
            EditorGUI.indentLevel++;
            PropertyField(_overlayTexture, Labels.Texture);
            PropertyField(_overlayOpacity, Labels.Opacity);
            EditorGUI.indentLevel--;
        }
    }
}

} // namespace Kino.PostProcessing
