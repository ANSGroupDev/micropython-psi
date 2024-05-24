include("$(PORT_DIR)/boards/PYBD_SF2/manifest.py")
package("psiutils", base_path="$(PORT_DIR)/modules")

# # any other required modules already in mpy dist
# require("lsm6dsox")