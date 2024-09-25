haxe sussy.hxml
haxe cellui.hxml
haxe celluitest.hxml
haxe celluiexecutor.hxml
X1=$(cat celluidesigner/src/cellui/cellui.js)
echo "
var exports = {};
$X1;
export default exports;" > celluidesigner/src/cellui/cellui.js
