import pathlib
import sys
import tempfile

try:
    import hou

    if len(sys.argv) != 2:
        raise ValueError("usage: smoke-test.py <output-scene-under-temp>")
    output = pathlib.Path(sys.argv[1]).resolve()
    temp = pathlib.Path(tempfile.gettempdir()).resolve()
    if temp != output and temp not in output.parents:
        raise ValueError(f"output must be under the Windows temporary directory: {temp}")
    output.parent.mkdir(parents=True, exist_ok=True)
    print("Houdini", hou.applicationVersionString())
    geo = hou.node("/obj").createNode("geo", "native_windows_smoke")
    geo.createNode("box", "box1")
    hou.hipFile.save(str(output))
    print(f"Saved {output}")
except Exception as exc:
    print(f"Houdini smoke test failed: {exc}", file=sys.stderr)
    raise
