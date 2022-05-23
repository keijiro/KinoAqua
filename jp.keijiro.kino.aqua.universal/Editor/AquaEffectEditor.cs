using UnityEngine;
using UnityEditor;

namespace Kino.Aqua.Universal {

[CanEditMultipleObjects]
[CustomEditor(typeof(AquaEffect))]
sealed class AquaEffectEditor : Editor
{
    AutoProperty _opacity;
    AutoProperty _edgeColor;
    AutoProperty _edgeContrast;
    AutoProperty _fillColor;
    AutoProperty _blurWidth;
    AutoProperty _blurFrequency;
    AutoProperty _hueShift;
    AutoProperty _interval;
    AutoProperty _iteration;
    AutoProperty _overlayMode;
    AutoProperty _overlayTexture;
    AutoProperty _overlayOpacity;

    static class Labels
    {
        public static Label Texture = "Texture";
        public static Label Opacity = "Opacity";
    }

    public void OnEnable()
      => AutoProperty.Scan(this);

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.PropertyField(_opacity.Target);

        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(_edgeColor.Target);
        EditorGUILayout.PropertyField(_edgeContrast.Target);

        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(_fillColor.Target);
        EditorGUILayout.PropertyField(_blurWidth.Target);
        EditorGUILayout.PropertyField(_blurFrequency.Target);
        EditorGUILayout.PropertyField(_hueShift.Target);

        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(_interval.Target);
        EditorGUILayout.PropertyField(_iteration.Target);

        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(_overlayMode.Target);
        if (_overlayMode.Target.hasMultipleDifferentValues ||
            _overlayMode.Target.enumValueIndex != 0)
        {
            EditorGUI.indentLevel++;
            EditorGUILayout.PropertyField(_overlayTexture.Target, Labels.Texture);
            EditorGUILayout.PropertyField(_overlayOpacity.Target, Labels.Opacity);
            EditorGUI.indentLevel--;
        }

        serializedObject.ApplyModifiedProperties();
    }
}

} // namespace Kino.Aqua.Universal
