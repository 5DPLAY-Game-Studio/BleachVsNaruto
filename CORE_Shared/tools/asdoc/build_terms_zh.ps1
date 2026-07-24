# =============================================================================
# build_terms_zh.ps1
#
# Purpose
#   Read the Flex SDK English ASDoc_terms.xml, replace chrome labels using the
#   maps below, and write tools/asdoc/zh_CN/ASDoc_terms.xml for asdoc.bat to
#   overlay into the local templates copy.
#
# Why
#   ASDoc has no built-in Chinese locale. UI chrome ("All Classes", "Properties",
#   ...) comes from ASDoc_terms.xml in the templates. API body text still follows
#   source ASDoc comments; this script only translates the shell labels.
#
# Usage
#   Normally invoked by tools/asdoc.bat. Standalone:
#     powershell -NoProfile -ExecutionPolicy Bypass -File tools/asdoc/build_terms_zh.ps1
#   Requires FLEX_HOME (SDK must contain asdoc\templates\ASDoc_terms.xml).
#
# How to add translations
#   1) Open zh_CN/untranslated_candidates.txt (refreshed at end of each run)
#   2) Prefer $keyMap (by Key); use $valMap when many Keys share one English value
#   3) Put Chinese as \uXXXX escapes only -- never raw non-ASCII in THIS file
#   4) Re-run asdoc.bat (re-runs this script and regenerates HTML)
#
# Encoding (critical)
#   This file MUST stay ASCII-only (comments and code). Editors/consoles that
#   mis-decode UTF-8 would corrupt the script. Function U expands '\uXXXX' into
#   real Unicode when writing the output XML.
#
# Outputs
#   zh_CN/ASDoc_terms.xml              Chinese terms for -templates-path
#   zh_CN/untranslated_candidates.txt  Remaining English-looking rows (Key\tValue)
# =============================================================================

$ErrorActionPreference = 'Stop'
$flexHome = $env:FLEX_HOME
if (-not $flexHome) { throw 'FLEX_HOME is not set' }

# Source = SDK English template; output dir = zh_CN next to this script
$src = Join-Path $flexHome 'asdoc\templates\ASDoc_terms.xml'
$outDir = Join-Path $PSScriptRoot 'zh_CN'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# Expand \uXXXX escapes to chars; leave ordinary ASCII unchanged
function U([string]$s) {
    return [regex]::Replace($s, '\\u([0-9a-fA-F]{4})', {
        param($m) [char]([Convert]::ToInt32($m.Groups[1].Value, 16))
    })
}

# -----------------------------------------------------------------------------
# $keyMap: term-table Key -> Chinese (preferred match)
# Keys match column 1 of SDK ASDoc_terms.xml (e.g. allClasses, DefinedBy).
# -----------------------------------------------------------------------------
$keyMap = @{}
@(
    @('AS2tooltip', '\u8be5\u793a\u4f8b\u9700\u8981 ActionScript 2.0'),
    @('AS3tooltip', '\u8be5\u793a\u4f8b\u9700\u8981 ActionScript 3.0'),
    @('Type', '\u7c7b\u578b'),
    @('Format', '\u683c\u5f0f'),
    @('Properties', '\u5c5e\u6027'),
    @('Property', '\u5c5e\u6027'),
    @('PropertyProperty', '\u5c5e\u6027'),
    @('Constructor', '\u6784\u9020\u51fd\u6570'),
    @('Methods', '\u65b9\u6cd5'),
    @('Method', '\u65b9\u6cd5'),
    @('MethodMethod', '\u65b9\u6cd5'),
    @('Functions', '\u51fd\u6570'),
    @('Function', '\u51fd\u6570'),
    @('FunctionFunction', '\u51fd\u6570'),
    @('Events', '\u4e8b\u4ef6'),
    @('Event', '\u4e8b\u4ef6'),
    @('Styles', '\u6837\u5f0f'),
    @('Effects', '\u6548\u679c'),
    @('Constants', '\u5e38\u91cf'),
    @('Constant', '\u5e38\u91cf'),
    @('Interface', '\u63a5\u53e3'),
    @('Classes', '\u7c7b'),
    @('ClassClass', '\u7c7b'),
    @('Example', '\u793a\u4f8b'),
    @('Examples', '\u793a\u4f8b'),
    @('allClasses', '\u6240\u6709\u7c7b'),
    @('LanguageElements', '\u8bed\u8a00\u5143\u7d20'),
    @('Index', '\u7d22\u5f15'),
    @('Frames', '\u6846\u67b6'),
    @('seeAlso', '\u53e6\u8bf7\u53c2\u9605'),
    @('Protected', '\u53d7\u4fdd\u62a4'),
    @('Public', '\u516c\u5171'),
    @('Package', '\u5305'),
    @('PackagePackage', '\u5305'),
    @('Packages', '\u5305'),
    @('Parameters', '\u53c2\u6570'),
    @('Throws', '\u629b\u51fa'),
    @('Returns', '\u8fd4\u56de'),
    @('Deprecated', '\u5df2\u5f03\u7528'),
    @('DeprecatedAsOf', '\u5df2\u5f03\u7528'),
    @('DeprecatedIn', '\u5df2\u5f03\u7528'),
    @('Static', '\u9759\u6001'),
    @('Search', '\u641c\u7d22'),
    @('SkinStates', '\u76ae\u80a4\u72b6\u6001'),
    @('SkinParts', '\u76ae\u80a4\u90e8\u4ef6'),
    @('PublicProperties', '\u516c\u5171\u5c5e\u6027'),
    @('ProtectedMethods', '\u53d7\u4fdd\u62a4\u65b9\u6cd5'),
    @('PublicMethods', '\u516c\u5171\u65b9\u6cd5'),
    @('ProtectedProperties', '\u53d7\u4fdd\u62a4\u5c5e\u6027'),
    @('StaticMethods', '\u9759\u6001\u65b9\u6cd5'),
    @('StaticProperties', '\u9759\u6001\u5c5e\u6027'),
    @('Inherited', '\u7ee7\u627f'),
    @('FPH_All_Classes', '\u6240\u6709\u7c7b'),
    @('FPH_Methods', '\u65b9\u6cd5'),
    @('FPH_Properties', '\u5c5e\u6027'),
    @('FPH_Events', '\u4e8b\u4ef6'),
    @('FPH_Styles', '\u6837\u5f0f'),
    @('FPH_Functions', '\u51fd\u6570'),
    @('FPH_Constants', '\u5e38\u91cf'),
    @('FPH_Constructor', '\u6784\u9020\u51fd\u6570'),
    @('FPH_Class', '\u7c7b'),
    @('FPH_Interface', '\u63a5\u53e3'),
    @('FPH_Index_Name', '\u7d22\u5f15'),
    @('FPH_Lang_Elements_Name', '\u8bed\u8a00\u5143\u7d20'),
    @('MethodIn', '\u65b9\u6cd5'),
    @('ConstructorInClass', '\u6784\u9020\u51fd\u6570'),
    @('PropertyIn', '\u5c5e\u6027'),
    @('EventIn', '\u4e8b\u4ef6'),
    @('InterfaceIn', '\u63a5\u53e3'),
    @('ClassIn', '\u7c7b'),
    @('File', '\u6587\u4ef6'),
    @('Home', '\u9996\u9875'),
    @('Overview', '\u6982\u89c8'),
    @('Appendices', '\u9644\u5f55'),
    @('Namespaces', '\u547d\u540d\u7a7a\u95f4'),
    @('Namespace', '\u547d\u540d\u7a7a\u95f4'),
    @('Version', '\u7248\u672c'),
    @('RuntimeVersions', '\u8fd0\u884c\u65f6\u7248\u672c'),
    @('ProductVersion', '\u4ea7\u54c1\u7248\u672c'),
    @('LanguageVersion', '\u8bed\u8a00\u7248\u672c'),
    @('PlayerVersion', '\u64ad\u653e\u5668\u7248\u672c'),
    @('See', '\u53c2\u89c1'),
    @('Default', '\u9ed8\u8ba4'),
    @('InheritedFrom', '\u7ee7\u627f\u81ea'),
    @('Subclasses', '\u5b50\u7c7b'),
    @('Implements', '\u5b9e\u73b0'),
    @('ImplementedBy', '\u5b9e\u73b0\u8005'),
    @('RelatedAPIElements', '\u76f8\u5173 API \u5143\u7d20'),
    @('ShowInheritedPublicProperties', '\u663e\u793a\u7ee7\u627f\u7684\u516c\u5171\u5c5e\u6027'),
    @('HideInheritedPublicProperties', '\u9690\u85cf\u7ee7\u627f\u7684\u516c\u5171\u5c5e\u6027'),
    @('ShowInheritedProtectedProperties', '\u663e\u793a\u7ee7\u627f\u7684\u53d7\u4fdd\u62a4\u5c5e\u6027'),
    @('HideInheritedProtectedProperties', '\u9690\u85cf\u7ee7\u627f\u7684\u53d7\u4fdd\u62a4\u5c5e\u6027'),
    @('ShowInheritedPublicMethods', '\u663e\u793a\u7ee7\u627f\u7684\u516c\u5171\u65b9\u6cd5'),
    @('HideInheritedPublicMethods', '\u9690\u85cf\u7ee7\u627f\u7684\u516c\u5171\u65b9\u6cd5'),
    @('ShowInheritedProtectedMethods', '\u663e\u793a\u7ee7\u627f\u7684\u53d7\u4fdd\u62a4\u65b9\u6cd5'),
    @('HideInheritedProtectedMethods', '\u9690\u85cf\u7ee7\u627f\u7684\u53d7\u4fdd\u62a4\u65b9\u6cd5'),
    @('ShowInheritedEvents', '\u663e\u793a\u7ee7\u627f\u7684\u4e8b\u4ef6'),
    @('HideInheritedEvents', '\u9690\u85cf\u7ee7\u627f\u7684\u4e8b\u4ef6'),
    @('ShowInheritedStyles', '\u663e\u793a\u7ee7\u627f\u7684\u6837\u5f0f'),
    @('HideInheritedStyles', '\u9690\u85cf\u7ee7\u627f\u7684\u6837\u5f0f'),
    @('ShowInheritedConstants', '\u663e\u793a\u7ee7\u627f\u7684\u5e38\u91cf'),
    @('HideInheritedConstants', '\u9690\u85cf\u7ee7\u627f\u7684\u5e38\u91cf'),
    @('NoProperties', '\u6ca1\u6709\u5c5e\u6027'),
    @('NoMethods', '\u6ca1\u6709\u65b9\u6cd5'),
    @('NoEvents', '\u6ca1\u6709\u4e8b\u4ef6'),
    @('NoStyles', '\u6ca1\u6709\u6837\u5f0f'),
    @('NoEffects', '\u6ca1\u6709\u6548\u679c'),
    @('NoConstants', '\u6ca1\u6709\u5e38\u91cf'),
    @('NoConstructor', '\u6ca1\u6709\u6784\u9020\u51fd\u6570'),
    @('NoParameters', '\u6ca1\u6709\u53c2\u6570'),
    @('NoExamples', '\u6ca1\u6709\u793a\u4f8b'),
    @('ViewSource', '\u67e5\u770b\u6e90\u7801'),
    @('Top', '\u9876\u90e8'),
    @('Bottom', '\u5e95\u90e8'),
    @('Previous', '\u4e0a\u4e00\u9875'),
    @('Next', '\u4e0b\u4e00\u9875'),
    @('AllPackages', '\u6240\u6709\u5305'),
    @('ClassInheritance', '\u7c7b\u7ee7\u627f'),
    @('PropertyDetail', '\u5c5e\u6027\u8be6\u60c5'),
    @('ConstructorDetail', '\u6784\u9020\u51fd\u6570\u8be6\u60c5'),
    @('MethodDetail', '\u65b9\u6cd5\u8be6\u60c5'),
    @('ConstantDetail', '\u5e38\u91cf\u8be6\u60c5'),
    @('Style', '\u6837\u5f0f'),
    @('Effect', '\u6548\u679c'),
    @('Interfaces', '\u63a5\u53e3'),
    @('Description', '\u63cf\u8ff0'),
    @('Conventions', '\u7ea6\u5b9a'),
    @('NoFrames', '\u65e0\u6846\u67b6'),
    @('All', '\u5168\u90e8'),
    @('TopLevel', '\u9876\u5c42'),
    @('Operator', '\u8fd0\u7b97\u7b26'),
    @('Operators', '\u8fd0\u7b97\u7b26'),
    @('Statement', '\u8bed\u53e5'),
    @('Statements', '\u8bed\u53e5'),
    @('SpecialType', '\u7279\u6b8a\u7c7b\u578b'),
    @('SpecialTypes', '\u7279\u6b8a\u7c7b\u578b'),
    @('SpecialTypeDetail', '\u7279\u6b8a\u7c7b\u578b\u8be6\u60c5'),
    @('Appendix', '\u9644\u5f55'),
    @('LanguageElement', '\u8bed\u8a00\u5143\u7d20'),
    @('CSSInheritance', 'CSS \u7ee7\u627f'),
    @('Use', '\u7528\u6cd5'),
    @('Usage', '\u7528\u6cd5'),
    @('ViewExamples', '\u67e5\u770b\u793a\u4f8b'),
    @('allMXPackages', '\u6240\u6709 MX \u5305'),
    @('allMXClasses', '\u6240\u6709 MX \u7c7b'),
    @('Unsupported', '\u4e0d\u652f\u6301'),
    @('DeprecatedText', '\u5df2\u5f03\u7528'),
    @('DeprecatedClassesHeader', '\u5df2\u5f03\u7528\u7684\u7c7b'),
    @('DeprecatedFunctionHeader', '\u5df2\u5f03\u7528\u7684\u51fd\u6570'),
    @('DeprecatedMethodHeader', '\u5df2\u5f03\u7528\u7684\u65b9\u6cd5'),
    @('DeprecatedPropertiesHeader', '\u5df2\u5f03\u7528\u7684\u5c5e\u6027'),
    @('InheritedPublicProperties', '\u7ee7\u627f\u7684\u516c\u5171\u5c5e\u6027'),
    @('InheritedProtectedProperties', '\u7ee7\u627f\u7684\u53d7\u4fdd\u62a4\u5c5e\u6027'),
    @('InheritedPublicMethods', '\u7ee7\u627f\u7684\u516c\u5171\u65b9\u6cd5'),
    @('InheritedProtectedMethods', '\u7ee7\u627f\u7684\u53d7\u4fdd\u62a4\u65b9\u6cd5'),
    @('InheritedEvents', '\u7ee7\u627f\u7684\u4e8b\u4ef6'),
    @('InheritedStyles', '\u7ee7\u627f\u7684\u6837\u5f0f'),
    @('InheritedConstants', '\u7ee7\u627f\u7684\u5e38\u91cf'),
    @('InheritedEffects', '\u7ee7\u627f\u7684\u6548\u679c'),
    @('InheritedSkinParts', '\u7ee7\u627f\u7684\u76ae\u80a4\u90e8\u4ef6'),
    @('InheritedSkinStates', '\u7ee7\u627f\u7684\u76ae\u80a4\u72b6\u6001'),
    @('EventDetail', '\u4e8b\u4ef6\u8be6\u60c5'),
    @('StyleDetail', '\u6837\u5f0f\u8be6\u60c5'),
    @('EffectDetail', '\u6548\u679c\u8be6\u60c5'),
    @('FunctionDetail', '\u51fd\u6570\u8be6\u60c5'),
    @('PackageHeader', '\u5305'),
    @('ClassHeader', '\u7c7b'),
    @('InterfaceHeader', '\u63a5\u53e3'),
    @('oldPlayerVersion', '\u8fd0\u884c\u65f6\u7248\u672c'),
    @('AS1tooltip', 'ActionScript 1.0 \u517c\u5bb9\u793a\u4f8b\u63d0\u793a'),
    @('DefinedBy', '\u5b9a\u4e49\u4e8e'),
    @('DefinedByEffects', '\u5b9a\u4e49\u4e8e'),
    @('DefinedByEvents', '\u5b9a\u4e49\u4e8e'),
    @('DefinedByMethods', '\u5b9a\u4e49\u4e8e'),
    @('DefinedByProperties', '\u5b9a\u4e49\u4e8e'),
    @('DefinedByStyles', '\u5b9a\u4e49\u4e8e'),
    @('DefinedIn', '\u5b9a\u4e49\u4e8e'),
    @('DefaultValueIs', '\u9ed8\u8ba4\u503c\u4e3a'),
    @('Details', '\u8be6\u60c5'),
    @('Inheritance', '\u7ee7\u627f'),
    @('Implementation', '\u5b9e\u73b0'),
    @('Implementors', '\u5b9e\u73b0\u8005'),
    @('Summary', '\u6458\u8981'),
    @('Since', '\u59cb\u4e8e'),
    @('DeprecatedSince', '\u5f03\u7528\u4e8e'),
    @('Required', '\u5fc5\u9700'),
    @('Result', '\u7ed3\u679c'),
    @('Global', '\u5168\u5c40'),
    @('SearchResults', '\u641c\u7d22\u7ed3\u679c'),
    @('PackageList', '\u5305\u5217\u8868'),
    @('Pleaseuse', '\u8bf7\u4f7f\u7528'),
    @('TriggeringEvent', '\u89e6\u53d1\u4e8b\u4ef6'),
    @('ShowInheritedEffects', '\u663e\u793a\u7ee7\u627f\u7684\u6548\u679c'),
    @('HideInheritedEffects', '\u9690\u85cf\u7ee7\u627f\u7684\u6548\u679c'),
    @('ShowInheritedMethods', '\u663e\u793a\u7ee7\u627f\u7684\u65b9\u6cd5'),
    @('ShowInheritedProperties', '\u663e\u793a\u7ee7\u627f\u7684\u5c5e\u6027'),
    @('ShowInheritedPublicConstants', '\u663e\u793a\u7ee7\u627f\u7684\u516c\u5171\u5e38\u91cf'),
    @('HideInheritedPublicConstants', '\u9690\u85cf\u7ee7\u627f\u7684\u516c\u5171\u5e38\u91cf'),
    @('ShowInheritedProtectedConstants', '\u663e\u793a\u7ee7\u627f\u7684\u53d7\u4fdd\u62a4\u5e38\u91cf'),
    @('HideInheritedProtectedConstants', '\u9690\u85cf\u7ee7\u627f\u7684\u53d7\u4fdd\u62a4\u5e38\u91cf'),
    @('ShowInheritedSkinParts', '\u663e\u793a\u7ee7\u627f\u7684\u76ae\u80a4\u90e8\u4ef6'),
    @('HideInheritedSkinParts', '\u9690\u85cf\u7ee7\u627f\u7684\u76ae\u80a4\u90e8\u4ef6'),
    @('ShowInheritedSkinStates', '\u663e\u793a\u7ee7\u627f\u7684\u76ae\u80a4\u72b6\u6001'),
    @('HideInheritedSkinStates', '\u9690\u85cf\u7ee7\u627f\u7684\u76ae\u80a4\u72b6\u6001'),
    @('ShowMXMLSyntax', '\u663e\u793a MXML \u8bed\u6cd5'),
    @('HideMXMLSyntax', '\u9690\u85cf MXML \u8bed\u6cd5'),
    @('PublicConstants', '\u516c\u5171\u5e38\u91cf'),
    @('ProtectedConstants', '\u53d7\u4fdd\u62a4\u5e38\u91cf'),
    @('SkinPart', '\u76ae\u80a4\u90e8\u4ef6'),
    @('SkinState', '\u76ae\u80a4\u72b6\u6001'),
    @('PartType', '\u90e8\u4ef6\u7c7b\u578b'),
    @('OperatorDetail', '\u8fd0\u7b97\u7b26\u8be6\u60c5'),
    @('ProductVersions', '\u4ea7\u54c1\u7248\u672c'),
    @('GlobalConstants', '\u5168\u5c40\u5e38\u91cf'),
    @('GlobalFunctions', '\u5168\u5c40\u51fd\u6570'),
    @('GlobalFunction', '\u5168\u5c40\u51fd\u6570'),
    @('GlobalMethods', '\u5168\u5c40\u65b9\u6cd5'),
    @('GlobalProperties', '\u5168\u5c40\u5c5e\u6027'),
    @('GlobalProperty', '\u5168\u5c40\u5c5e\u6027'),
    @('GlobalEventHandler', '\u5168\u5c40\u4e8b\u4ef6\u5904\u7406\u51fd\u6570'),
    @('GlobalEventListener', '\u5168\u5c40\u4e8b\u4ef6\u4fa6\u542c\u5668'),
    @('FPH_All_Packages', '\u6240\u6709\u5305'),
    @('FPH_Global', '\u5168\u5c40'),
    @('FPH_Top_Level_Classes', '\u9876\u5c42\u7c7b'),
    @('FPH_StatementsKeywordsDirectives', '\u8bed\u53e5\u3001\u5173\u952e\u5b57\u4e0e\u6307\u4ee4'),
    @('FPH_Index_Tip_Text', '\u6240\u6709\u7c7b\u3001\u65b9\u6cd5\u3001\u5c5e\u6027\u4e0e\u8bed\u8a00\u5143\u7d20\u7684\u7d22\u5f15'),
    @('FPH_Appendixes_Tip_Text', '\u94fe\u63a5\u5230\u9644\u5f55\u5217\u8868'),
    @('FPH_Conventions_Tip_Text', '\u94fe\u63a5\u5230\u7ea6\u5b9a\u5217\u8868'),
    @('FPH_Book_Title', 'ActionScript 3.0 \u8bed\u8a00\u4e0e\u7ec4\u4ef6\u53c2\u8003'),
    @('FunctionsMethods', '\u51fd\u6570\u4e0e\u65b9\u6cd5'),
    @('StatementsKeywords', '\u8bed\u53e5\u4e0e\u5173\u952e\u5b57'),
    @('TopLevelConstantsFunctions', '\u9876\u5c42\u5e38\u91cf\u4e0e\u51fd\u6570'),
    @('InnerClassSummary', '\u5185\u90e8\u7c7b\u6458\u8981'),
    @('EventHandlerIn', '\u4e8b\u4ef6\u5904\u7406\u51fd\u6570'),
    @('EventListenerIn', '\u4e8b\u4ef6\u4fa6\u542c\u5668'),
    @('EventObjectType', '\u4e8b\u4ef6\u5bf9\u8c61\u7c7b\u578b'),
    @('ConstantProperty', '\u5e38\u91cf\u5c5e\u6027'),
    @('ConstantPropertyIn', '\u5e38\u91cf\u5c5e\u6027'),
    @('ConstantStaticPropertyIn', '\u5e38\u91cf\u9759\u6001\u5c5e\u6027'),
    @('StaticMethodIn', '\u9759\u6001\u65b9\u6cd5'),
    @('StaticPropertyIn', '\u9759\u6001\u5c5e\u6027'),
    @('StaticTypeDefinedInClass', '\u7c7b\u4e2d\u5b9a\u4e49\u7684\u9759\u6001\u7c7b\u578b'),
    @('PackageFunctionIn', '\u5305\u7ea7\u51fd\u6570'),
    @('PackageStaticFunctionIn', '\u5305\u7ea7\u9759\u6001\u51fd\u6570'),
    @('PackageStaticPropertyIn', '\u5305\u7ea7\u9759\u6001\u5c5e\u6027'),
    @('PackageConstantPropertyIn', '\u5305\u7ea7\u5e38\u91cf\u5c5e\u6027'),
    @('PackageConstantStaticPropertyIn', '\u5305\u7ea7\u5e38\u91cf\u9759\u6001\u5c5e\u6027'),
    @('FinalClass', 'final \u7c7b'),
    @('FinalClassIn', 'final \u7c7b'),
    @('FinalDynamicClass', 'final dynamic \u7c7b'),
    @('FinalDynamicClassIn', 'final dynamic \u7c7b'),
    @('FinalPropertyIn', 'final \u5c5e\u6027'),
    @('FinalStaticPropertyIn', 'final \u9759\u6001\u5c5e\u6027'),
    @('DynamicClass', 'dynamic \u7c7b'),
    @('DynamicClassIn', 'dynamic \u7c7b'),
    @('Dynamic', '\u52a8\u6001'),
    @('UseExamples', '\u5982\u4f55\u4f7f\u7528\u793a\u4f8b'),
    @('ExampleInstruct', '\u5982\u4f55\u5728 ActionScript 3.0 \u8bed\u8a00\u53c2\u8003\u4e2d\u4f7f\u7528\u793a\u4f8b'),
    @('DataBinding', '\u6b64\u5c5e\u6027\u53ef\u7528\u4f5c\u6570\u636e\u7ed1\u5b9a\u7684\u6e90\u3002'),
    @('DefaultMXMLProperty', '\u9ed8\u8ba4 MXML \u5c5e\u6027'),
    @('MXMLSyntax', 'MXML \u8bed\u6cd5'),
    @('MXMLOnly', '\u4ec5\u9650 MXML \u7684\u7ec4\u4ef6'),
    @('DeprecatedOperatorsHeader', '\u5df2\u5f03\u7528\u7684\u8fd0\u7b97\u7b26'),
    @('DeprecatedStylesHeader', '\u5df2\u5f03\u7528\u7684\u6837\u5f0f'),
    @('allFlashClasses', '\u6240\u6709 Flash \u7c7b'),
    @('allFlashPlayerPackages', '\u6240\u6709 Flash \u5305'),
    @('Legal Notices', '\u6cd5\u5f8b\u58f0\u660e'),
    @('List of deprecated elements', '\u5df2\u5f03\u7528\u5143\u7d20\u5217\u8868'),
    @('howtouseeffects', '\u5355\u51fb\u4ee5\u4e86\u89e3\u6709\u5173\u6548\u679c\u7684\u66f4\u591a\u4fe1\u606f'),
    @('howtouseevents', '\u5355\u51fb\u4ee5\u4e86\u89e3\u6709\u5173\u4e8b\u4ef6\u7684\u66f4\u591a\u4fe1\u606f'),
    @('howtouseskins', '\u5355\u51fb\u4ee5\u4e86\u89e3\u6709\u5173\u76ae\u80a4\u7684\u66f4\u591a\u4fe1\u606f'),
    @('howtousestyles', '\u5355\u51fb\u4ee5\u4e86\u89e3\u6709\u5173\u6837\u5f0f\u7684\u66f4\u591a\u4fe1\u606f'),
    @('terms_AHV_NO_SEARCH_TERM', '\u672a\u8f93\u5165\u641c\u7d22\u8bcd\u3002'),
    @('terms_AHV_SHORT_WORDS', '\u77ed\u8bcd\u548c\u5e38\u7528\u8bcd\u5df2\u4ece\u641c\u7d22\u6570\u636e\u5e93\u4e2d\u6392\u9664\u3002'),
    @('Operands', '\u64cd\u4f5c\u6570'),
    @('other', '\u5176\u4ed6'),
    @('only', '\u4ec5'),
    @('Message', '\u6d88\u606f'),
    @('Metadata', '\u5143\u6570\u636e'),
    @('Theme', '\u4e3b\u9898'),
    @('Binding', '\u7ed1\u5b9a'),
    @('Component', '\u7ec4\u4ef6'),
    @('Comments', '\u6ce8\u91ca'),
    @('comment', '\u6ce8\u91ca'),
    @('Symbols', '\u7b26\u53f7'),
    @('SymbolsIndex', '\u7b26\u53f7\u7d22\u5f15'),
    @('Supported Character Sets', '\u652f\u6301\u7684\u5b57\u7b26\u96c6'),
    @('Character Set Codes', '\u5b57\u7b26\u96c6\u4ee3\u7801'),
    @('CharacterSetCodes', '\u5b57\u7b26\u96c6\u4ee3\u7801'),
    @('Compiler Errors', '\u7f16\u8bd1\u5668\u9519\u8bef'),
    @('CompilerErrors', '\u7f16\u8bd1\u5668\u9519\u8bef'),
    @('Compiler Warnings', '\u7f16\u8bd1\u5668\u8b66\u544a'),
    @('CompilerWarnings', '\u7f16\u8bd1\u5668\u8b66\u544a'),
    @('CompilerDirective', '\u7f16\u8bd1\u5668\u6307\u4ee4'),
    @('CompilerDirectives', '\u7f16\u8bd1\u5668\u6307\u4ee4'),
    @('Run-Time Errors', '\u8fd0\u884c\u65f6\u9519\u8bef'),
    @('RunTimeErrors', '\u8fd0\u884c\u65f6\u9519\u8bef'),
    @('ActionScript2Migration', 'ActionScript 2.0 \u8fc1\u79fb'),
    @('ActionScript 2.0 Migration', 'ActionScript 2.0 \u8fc1\u79fb'),
    @('definition keyword', '\u5b9a\u4e49\u5173\u952e\u5b57'),
    @('attribute keyword', '\u7279\u6027\u5173\u952e\u5b57'),
    @('primary expression keyword', '\u4e3b\u8868\u8fbe\u5f0f\u5173\u952e\u5b57'),
    @('directive', '\u6307\u4ee4'),
    @('arithmetic', '\u7b97\u672f'),
    @('assignment', '\u8d4b\u503c'),
    @('bitwise', '\u6309\u4f4d'),
    @('comparison', '\u6bd4\u8f83'),
    @('logical', '\u903b\u8f91'),
    @('arithmetic compound assignment', '\u7b97\u672f\u590d\u5408\u8d4b\u503c'),
    @('bitwise compound assignment', '\u6309\u4f4d\u590d\u5408\u8d4b\u503c'),
    @('MotionXMLElements', 'Motion XML \u5143\u7d20'),
    @('Motion XML Elements', 'Motion XML \u5143\u7d20'),
    @('MXML Only Components', '\u4ec5\u9650 MXML \u7684\u7ec4\u4ef6'),
    @('SQLSupportInLocalDatabases', '\u672c\u5730\u6570\u636e\u5e93\u4e2d\u7684 SQL \u652f\u6301'),
    @('SQL support in local databases', '\u672c\u5730\u6570\u636e\u5e93\u4e2d\u7684 SQL \u652f\u6301'),
    @('SQLError_detail_messages', 'SQL \u9519\u8bef\u8be6\u7ec6\u6d88\u606f\u3001ID \u4e0e\u53c2\u6570'),
    @('Timed Text Tags', 'Timed Text \u6807\u7b7e'),
    @('Timed Text XML Formats', 'Timed Text XML \u683c\u5f0f'),
    @('ApacheFlexLogo', 'Apache Flex \u5fbd\u6807'),
    @('Acrobat', 'Acrobat ActionScript API'),
    @('Model', '\u6a21\u578b'),
    @('Code', '\u4ee3\u7801'),
    @('Script', '\u811a\u672c'),
    @('read', '\u8bfb'),
    @('write', '\u5199'),
    @('unknown', '\u672a\u77e5'),
    @('windowruntimeproperty', 'window.runtime \u5c5e\u6027'),
    @('Using examples in the ActionScript 3.0 Language Reference', '\u5982\u4f55\u5728 ActionScript 3.0 \u8bed\u8a00\u53c2\u8003\u4e2d\u4f7f\u7528\u793a\u4f8b'),
    @('Using examples in the ActionScript 3.0 Language and Components Reference', '\u5982\u4f55\u5728 ActionScript 3.0 \u8bed\u8a00\u4e0e\u7ec4\u4ef6\u53c2\u8003\u4e2d\u4f7f\u7528\u793a\u4f8b'),
    @('Override', '\u91cd\u5199'),
    @('string', '\u5b57\u7b26\u4e32')
) | ForEach-Object { $keyMap[$_[0]] = (U $_[1]) }

# -----------------------------------------------------------------------------
# $valMap: English Value -> Chinese (fallback when keyMap misses)
# Use when several Keys share one English display string. Exact key match only.
# -----------------------------------------------------------------------------
$valMap = New-Object 'System.Collections.Generic.Dictionary[string,string]'
@(
    @('All Classes', '\u6240\u6709\u7c7b'),
    @('Properties', '\u5c5e\u6027'),
    @('Methods', '\u65b9\u6cd5'),
    @('Method', '\u65b9\u6cd5'),
    @('method', '\u65b9\u6cd5'),
    @('Functions', '\u51fd\u6570'),
    @('Function', '\u51fd\u6570'),
    @('function', '\u51fd\u6570'),
    @('Events', '\u4e8b\u4ef6'),
    @('Event', '\u4e8b\u4ef6'),
    @('Styles', '\u6837\u5f0f'),
    @('Effects', '\u6548\u679c'),
    @('Constants', '\u5e38\u91cf'),
    @('Constant', '\u5e38\u91cf'),
    @('Constructor', '\u6784\u9020\u51fd\u6570'),
    @('Interface', '\u63a5\u53e3'),
    @('interface', '\u63a5\u53e3'),
    @('Classes', '\u7c7b'),
    @('Class', '\u7c7b'),
    @('class', '\u7c7b'),
    @('Example', '\u793a\u4f8b'),
    @('Examples', '\u793a\u4f8b'),
    @('Language Elements', '\u8bed\u8a00\u5143\u7d20'),
    @('Index', '\u7d22\u5f15'),
    @('Frames', '\u6846\u67b6'),
    @('See also', '\u53e6\u8bf7\u53c2\u9605'),
    @('Protected', '\u53d7\u4fdd\u62a4'),
    @('Public', '\u516c\u5171'),
    @('Package', '\u5305'),
    @('package', '\u5305'),
    @('Packages', '\u5305'),
    @('Parameters', '\u53c2\u6570'),
    @('Throws', '\u629b\u51fa'),
    @('Returns', '\u8fd4\u56de'),
    @('Deprecated', '\u5df2\u5f03\u7528'),
    @('static', '\u9759\u6001'),
    @('Static', '\u9759\u6001'),
    @('Search', '\u641c\u7d22'),
    @('Skin States', '\u76ae\u80a4\u72b6\u6001'),
    @('Skin Parts', '\u76ae\u80a4\u90e8\u4ef6'),
    @('Public Properties', '\u516c\u5171\u5c5e\u6027'),
    @('Protected Methods', '\u53d7\u4fdd\u62a4\u65b9\u6cd5'),
    @('Public Methods', '\u516c\u5171\u65b9\u6cd5'),
    @('Type', '\u7c7b\u578b'),
    @('Format', '\u683c\u5f0f'),
    @('Property', '\u5c5e\u6027'),
    @('property', '\u5c5e\u6027'),
    @('Property Detail', '\u5c5e\u6027\u8be6\u60c5'),
    @('Constructor Detail', '\u6784\u9020\u51fd\u6570\u8be6\u60c5'),
    @('Method Detail', '\u65b9\u6cd5\u8be6\u60c5'),
    @('Constant Detail', '\u5e38\u91cf\u8be6\u60c5'),
    @('Event Detail', '\u4e8b\u4ef6\u8be6\u60c5'),
    @('Style Detail', '\u6837\u5f0f\u8be6\u60c5'),
    @('Effect Detail', '\u6548\u679c\u8be6\u60c5'),
    @('Function Detail', '\u51fd\u6570\u8be6\u60c5'),
    @('Description', '\u63cf\u8ff0'),
    @('Interfaces', '\u63a5\u53e3'),
    @('No Frames', '\u65e0\u6846\u67b6'),
    @('Top Level', '\u9876\u5c42'),
    @('Language Element', '\u8bed\u8a00\u5143\u7d20'),
    @('CSS Inheritance', 'CSS \u7ee7\u627f'),
    @('View the examples', '\u67e5\u770b\u793a\u4f8b'),
    @('All MX Packages', '\u6240\u6709 MX \u5305'),
    @('All MX Classes', '\u6240\u6709 MX \u7c7b'),
    @('Runtime Versions', '\u8fd0\u884c\u65f6\u7248\u672c'),
    @('Deprecated Classes', '\u5df2\u5f03\u7528\u7684\u7c7b'),
    @('Deprecated Methods', '\u5df2\u5f03\u7528\u7684\u65b9\u6cd5'),
    @('Deprecated Properties', '\u5df2\u5f03\u7528\u7684\u5c5e\u6027'),
    @('Inherited', '\u7ee7\u627f'),
    @('All', '\u5168\u90e8'),
    @('Operators', '\u8fd0\u7b97\u7b26'),
    @('Operator', '\u8fd0\u7b97\u7b26'),
    @('Statements', '\u8bed\u53e5'),
    @('Statement', '\u8bed\u53e5'),
    @('Special Types', '\u7279\u6b8a\u7c7b\u578b'),
    @('Special Type', '\u7279\u6b8a\u7c7b\u578b'),
    @('Appendixes', '\u9644\u5f55'),
    @('Style', '\u6837\u5f0f'),
    @('Effect', '\u6548\u679c'),
    @('Use', '\u7528\u6cd5'),
    @('Usage', '\u7528\u6cd5'),
    @('Unsupported', '\u4e0d\u652f\u6301'),
    @('Conventions', '\u7ea6\u5b9a')
) | ForEach-Object { $valMap[$_[0]] = (U $_[1]) }

# -----------------------------------------------------------------------------
# Walk SDK term rows: two entries per row (Key / Value). Prefer keyMap, else valMap.
# Prefer <p> without @translate on the Value side (matches SDK table layout).
# -----------------------------------------------------------------------------
[xml]$doc = Get-Content -LiteralPath $src -Encoding UTF8
$changed = 0
foreach ($row in $doc.SelectNodes('//row')) {
    $entries = @($row.SelectNodes('entry'))
    if ($entries.Count -lt 2) { continue }
    $keyP = $entries[0].SelectSingleNode('.//p')
    $valP = $entries[1].SelectSingleNode('.//p[not(@translate)]')
    if (-not $valP) { $valP = $entries[1].SelectSingleNode('.//p') }
    if (-not $keyP -or -not $valP) { continue }
    $key = $keyP.InnerText.Trim()
    $old = $valP.InnerText.Trim()
    $new = $null
    if ($keyMap.ContainsKey($key)) { $new = $keyMap[$key] }
    elseif ($valMap.ContainsKey($old)) { $new = $valMap[$old] }
    if ($new -and $new -ne $old) {
        $valP.InnerText = $new
        $changed++
    }
}

# Write UTF-8 without BOM (some XML/XSL tools dislike BOM)
$outFile = Join-Path $outDir 'ASDoc_terms.xml'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Encoding = $utf8
$settings.Indent = $true
$writer = [System.Xml.XmlWriter]::Create($outFile, $settings)
$doc.Save($writer)
$writer.Close()
Write-Host "changed=$changed out=$outFile"

# -----------------------------------------------------------------------------
# List Values that still look English (heuristic). Not all need translation
# (e.g. book metadata, type names like XML). Format: Key<TAB>Value.
# Heuristic: starts with a letter; mostly ASCII letters/digits/light punctuation.
# -----------------------------------------------------------------------------
$remainFile = Join-Path $outDir 'untranslated_candidates.txt'
$remain = New-Object System.Collections.Generic.List[string]
foreach ($row in $doc.SelectNodes('//row')) {
    $entries = @($row.SelectNodes('entry'))
    if ($entries.Count -lt 2) { continue }
    $keyP = $entries[0].SelectSingleNode('.//p')
    $valP = $entries[1].SelectSingleNode('.//p[not(@translate)]')
    if (-not $valP) { $valP = $entries[1].SelectSingleNode('.//p') }
    if (-not $keyP -or -not $valP) { continue }
    $key = $keyP.InnerText.Trim()
    $val = $valP.InnerText.Trim()
    if ($key -eq 'Key (or Paragraph tag)') { continue }
    if ($val -cmatch '^[A-Za-z][A-Za-z0-9 ,|/_.''-]{1,100}$') {
        $remain.Add("$key`t$val")
    }
}
$remain | Sort-Object -Unique | Set-Content -LiteralPath $remainFile -Encoding UTF8
Write-Host "remaining_candidates=$($remain.Count) list=$remainFile"
