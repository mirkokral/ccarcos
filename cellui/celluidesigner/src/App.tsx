import { ReactElement, useEffect, useRef, useState } from "react";
import "./App.css";
import x, { SimpleContainer } from "./cellui/cellui";
import "beercss";
import basecode from "./base.txt?raw";
import MonacoEditor from "react-monaco-editor";

//@ts-ignore
const t: x.typedefs_Simpleterminal = new x.typedefs.Simpleterminal((s: string) => { })
const rnd = new x.Renderer(t);
const l = new x.Label(0, 0, "left!");
l.id = "datelabel"
l.xa = 0;
const l2 = new x.Label(0, 0, "center!");
l2.id = "clocklabel"
l2.xa = 0.5;
l2.style.bgColor = x.Colors.red;
l2.style.fgColor = x.Colors.green;
const l3 = new x.Label(0, 0, "right!");
l3.id = "rightlabel"
l3.xa = 1;
const l4 = new x.TextArea(10, 2, "Amogus\n(in multiline)");
l4.id = "amoglabel"
l4.width = 10;
l4.height = 4;
l4.style.bgColor = x.Colors.gray;
// l4.style.bgColor = x.Colors.red;
let screens = new x.ScreenManager(t);
screens.addScreen(new x.SimpleContainer([l, l2, l3, l4]))
const addableWidgets = {
  "Container": () => {
    var cont = new x.SimpleContainer([]);
    cont.x = 1;
    cont.y = 1;
    screens.current().addChild(cont);
    return cont.id;
  },
  "Scrollable Container": () => {
    var cont = new x.ScrollContainer([]);
    cont.x = 1;
    cont.y = 1;
    screens.current().addChild(cont);
    return cont.id;
  },
  "Label": () => {
    let c = new x.Label(1, 1, "Use the left pane to edit the text.");
    screens.current().addChild(c);
    return c.id;
  },
  "Button": () => {
    let b = new x.Button([new x.Label(1, 1, "Hello, world!")], new x.Command("execLua", "print('Hello, world!')", new x.Transition("left")));
    screens.current().addChild(b);
    return b.id
  },
  "Text Area": () => {
    let b = new x.TextArea(1, 1, "Hello, world!");
    screens.current().addChild(b);
    return b.id;
  },
  "Screen": () => {
    let s = new x.SimpleContainer([]);
    screens.addScreen(s)
    screens.currentScreen = screens.screens.length - 1;

    return s.id
  },
};
let xCallback = () => {};
function App() {
  const cRef = useRef<HTMLCanvasElement>(null);
  const dRef = useRef<HTMLInputElement>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [copyDialogOpen, setCopyDialogOpen] = useState(false);
  const [loadDialogOpen, setLoadDialogOpen] = useState(false);
  const [editTransitionShown, setETS] = useState(false);
  const [useFullColorrange, _] = useState(false);
  const [navShown, setNavShown] = useState(true);
  const [xa, setXA] = useState(0);
  const [selectedElementID, setSED] = useState("");
  const [copyDialogTest, setCDT] = useState("");
  const [editingTransition, setET] = useState(new x.Command("execLua", "print('hi')", new x.Transition("right", "over", "ease", 1000)));
  const [termSize, setTermSize] = useState(new x.Vector2f(51, 19));
  // const fitAddon = new FitAddon();
  const [imd, setIMD] = useState(0);
  function HierarchyElement(object: x.Widget): ReactElement {
    return <div key={object.id} className="" style={{ paddingLeft: "2em" }}>
      <p draggable className="hierarchyElement row" onClick={() => setSED(object.id)} onDragStart={(e) => {
        e.dataTransfer.setData("id", object.id);
      }} onDrop={(e) => {
        //console.log("dropped element " + e.dataTransfer.getData("id"));
        var elem = screens.current().getChildByID(e.dataTransfer.getData("id"));
        var id = e.dataTransfer.getData("id");
        screens.current().children = screens.current().recFilterChildrenUF((e) => e.id != id);
        screens.current().children.reverse();
        if (object.id == screens.current().id) {
          screens.current().addChild(elem);

        } else {
          object.addChild(elem);
        }
        render();
        setXA(xa + 1);
      }} onDragOver={(e) => e.preventDefault()}>{object.getTypename()} - {object.id}</p>
      <div className="scroll">
        {object.children.map(e => HierarchyElement(e))}
      </div>
    </div>
  }
  function Entry(valuename: any, object: any): ReactElement {
    switch (typeof (object[valuename])) {
      case "boolean":
        return <label className="switch">
          <input type="checkbox" checked={object[valuename]} onChange={e => {
            object[valuename] = e.currentTarget.checked;
            render();
            setXA(xa + 1);
          }} />
          <span></span>
        </label>;
        break;

      case "number":
        if (valuename == "xa" || valuename == "ya") {
          return <nav className="no-space">
            <button className={"left-round border" + (object[valuename] == 0.0 ? " fill" : "")} onClick={() => {
              object[valuename] = 0.0; render(); setXA(xa + 1)
            }}>
              0.0
            </button>
            <button className={"no-round border" + (object[valuename] == 0.5 ? " fill" : "")} onClick={() => {

              object[valuename] = 0.5; render(); setXA(xa + 1)
            }}>
              0.5
            </button>
            <button className={"right-round border" + (object[valuename] == 1.0 ? " fill" : "")} onClick={() => { object[valuename] = 1.0; render(); setXA(xa + 1) }}>
              1.0
            </button>
          </nav>
        } else {
          return <div className="field no-margin">
            <input type="number" onChange={(e) => { object[valuename] = e.target.valueAsNumber; setXA(xa + 1); render() }} value={object[valuename]} />
          </div>
        }
        break;
      case "string":
        return <div className="field no-margin">
          <textarea value={object[valuename]} onChange={(e) => {
            if (valuename == "id") {
              setSED(e.currentTarget.value);
            }
            object[valuename] = e.currentTarget.value;
            render();
            setXA(xa + 1);
          }}></textarea>
        </div>;
        break;
      case "object":
        if (object[valuename].type && object[valuename].value && object[valuename].transition) {
          return <div className="padding">
            {object[valuename].type == "goToScreen" && [<button onClick={() => {setET(object[valuename]); xCallback = (() => {
              
            }); setETS(true)}}>
              Edit transition
            </button>, <br className=""></br>]}

            <button>
              {(() => {
                var x = "Invalid";
                switch (object[valuename].type) {
                  case "goToScreen":
                    x = "Change Screen";
                    break;
                  case "execLua":
                    x = "Execute Code";
                    break;
                }
                return <p>{x}</p>
              })()}
              <i>arrow_drop_down</i>
              <menu>
                <a onClick={() => { object[valuename].type = "goToScreen"; object[valuename].value = "0"; render() }}>Change Screen</a>
                <a onClick={() => { object[valuename].type = "execLua"; render() }}>Execute Code</a>
              </menu>
            </button>
            <br className="margin"></br>
            {(() => {
              switch (object[valuename].type) {
                case "goToScreen":
                  return <button>

                    {parseInt(object[valuename].value) + 1}
                    <i>arrow_drop_down</i>
                    <menu>
                      {(() => {
                        let xa = []
                        for (let i = 0; i < screens.screens.length; i++) {
                          xa.push(<a onClick={() => {
                            object[valuename].value = i.toString();
                            setXA(Math.random())
                          }}>
                            {i + 1}
                          </a>)
                        }
                        return xa
                      })()}
                    </menu>
                  </button>;
                  break;
                case "execLua":
                  return <button>Change code</button>
                default:
                  return <></>;
                  break;
              }
            })()}
          </div>
        } else if (object[valuename].blit) {
          var f = object[valuename].blit;
          var v = (() => {
            switch (f) {
              case "0": return <p>White</p>;
              case "1": return <p>Orange</p>;
              case "2": return <p>Magenta</p>;
              case "3": return <p>Light Blue</p>;
              case "4": return <p>Yellow</p>;
              case "5": return <p>Lime</p>;
              case "6": return <p>Pink</p>;
              case "7": return <p>Gray</p>;
              case "8": return <p>Light Gray</p>;
              case "9": return <p>Cyan</p>;
              case "a": return <p>Purple</p>;
              case "b": return <p>Blue</p>;
              case "c": return <p>Brown</p>;
              case "d": return <p>Green</p>;
              case "e": return <p>Red</p>;
              case "f": return <p>Black</p>;
              default: return <p>Invalid color, cannot be edited.</p>;
            }
          })()
          return <><p className="max">{valuename}</p><button className="">
            {v}
            <i>arrow_drop_down</i>
            <menu>
              <a key={"}}>White"} onClick={() => { object[valuename] = x.Colors.white; render(); setXA(xa + 1) }}>White</a>
              {useFullColorrange && <a key={"}}>Orange"} onClick={() => { object[valuename] = x.Colors.orange; render(); setXA(xa + 1) }}>Orange</a>}
              <a key={"}}>Magenta"} onClick={() => { object[valuename] = x.Colors.magenta; render(); setXA(xa + 1) }}>Magenta</a>
              {useFullColorrange && <a key={"Light Blue"} onClick={() => { object[valuename] = x.Colors.lightBlue; render(); setXA(xa + 1) }}>Light Blue</a>}
              <a key={"}}>Yellow"} onClick={() => { object[valuename] = x.Colors.yellow; render(); setXA(xa + 1) }}>Yellow</a>
              <a key={"}}>Lime"} onClick={() => { object[valuename] = x.Colors.lime; render(); setXA(xa + 1) }}>Lime</a>
              {useFullColorrange && <a key={"}}>Pink"} onClick={() => { object[valuename] = x.Colors.pink; render(); setXA(xa + 1) }}>Pink</a>}
              <a key={"}}>Gray"} onClick={() => { object[valuename] = x.Colors.gray; render(); setXA(xa + 1) }}>Gray</a>
              <a key={"Light Gray"} onClick={() => { object[valuename] = x.Colors.lightGray; render(); setXA(xa + 1) }}>Light Gray</a>
              <a key={"}}>Cyan"} onClick={() => { object[valuename] = x.Colors.cyan; render(); setXA(xa + 1) }}>Cyan</a>
              {useFullColorrange && <a key={"}}>Purple"} onClick={() => { object[valuename] = x.Colors.purple; render(); setXA(xa + 1) }}>Purple</a>}
              <a key={"}}>Blue"} onClick={() => { object[valuename] = x.Colors.blue; render(); setXA(xa + 1) }}>Blue</a>
              {useFullColorrange && <a key={"}}>Brown"} onClick={() => { object[valuename] = x.Colors.brown; render(); setXA(xa + 1) }}>Brown</a>}
              <a key={"}}>Green"} onClick={() => { object[valuename] = x.Colors.green; render(); setXA(xa + 1) }}>Green</a>
              <a key={"}}>Red"} onClick={() => { object[valuename] = x.Colors.red; render(); setXA(xa + 1) }}>Red</a>
              <a key={"}}>Black"} onClick={() => { object[valuename] = x.Colors.black; render(); setXA(xa + 1) }}>Black</a>
            </menu>
          </button><br /></>
        }
        return <div>
          {Object.keys(object[valuename]).map(e => {
            return Entry(e, object[valuename]);
          })}
        </div>
      default:
        return <p>This object ({typeof (object[valuename])}) cannot be edited.</p>

    }
  }

  const bsh = 24;
  const foffset = 4 * bsh / 16
  const csh = bsh + foffset;
  function render() {
    setXA(xa + 1);
    rnd.renderToBuffer(screens.current(), 0, 0, rnd.buffer1);
    const canvas = cRef.current;
    var x1 = -1;
    var y1 = -1;
    var x2 = -1;
    var y2 = -1;
    if (canvas) {
      const ctx = (canvas).getContext('2d');
      if (!ctx) throw new Error("No canvas");
      ctx.font = "24px Noto Sans Mono";
      let charsize = ctx.measureText("g");
      canvas.width = charsize.width * (rnd.buffer1.width);
      canvas.height = csh * (rnd.buffer1.height);
      rnd.buffer1.matrix.forEach((vy, iy) => {
        vy.forEach((vx, ix) => {

          ctx.font = "24px Noto Sans Mono";
          var red = t.get_palette()[vx.bgColor.palNumber].red.toString(16);
          if (red.length == 1) red = "0" + red;
          var green = t.get_palette()[vx.bgColor.palNumber].green.toString(16);
          if (green.length == 1) green = "0" + green;
          var blue = t.get_palette()[vx.bgColor.palNumber].blue.toString(16);
          if (blue.length == 1) blue = "0" + blue;
          ctx.fillStyle = `#${red}${green}${blue}`
          ctx.fillRect(ix * charsize.width, (iy) * (csh), charsize.width + 1, csh);
          var isss = false;
          try {
            screens.current().getChildByID(selectedElementID).getChildByID(vx.belongsToID);
            isss=true;
          } catch {};
          if(isss || vx.belongsToID == selectedElementID) {
            if(x1 == -1 && y1 == -1) {
              x1 = ix;
              y1 = iy;
            }
            x2 = Math.max(x2, ix);
            y2 = Math.max(y2, iy);
          }
  
        })
      })
      rnd.buffer1.matrix.forEach((vy, iy) => {
        vy.forEach((vx, ix) => {

          ctx.font = "24px Noto Sans Mono";
          var red = t.get_palette()[vx.fgColor.palNumber].red.toString(16);
          if (red.length == 1) red = "0" + red;
          var green = t.get_palette()[vx.fgColor.palNumber].green.toString(16);
          if (green.length == 1) green = "0" + green;
          var blue = t.get_palette()[vx.fgColor.palNumber].blue.toString(16);
          if (blue.length == 1) blue = "0" + blue;
          ctx.fillStyle = `#${red}${green}${blue}`
          ctx.fillText(vx.char, ix * charsize.width, (iy + 1) * csh - foffset);

        })
      })
      // try {
        ctx.strokeStyle = "#00FF00";
        ctx.strokeRect(x1*charsize.width, y1*csh, (x2-x1+1)*charsize.width, (y2-y1+1)*csh);
      // } catch { }
    }
  }
  function resizeTerm(xs: number, ys: number) {
    setTermSize(new x.Vector2f(xs, ys))
  }
  useEffect(() => {
    var xs = termSize.x;
    var ys = termSize.y;
    rnd.resize(xs, ys);
    screens.current().width = xs;
    screens.current().height = ys;
    render();
  }, [termSize]);
  useEffect(() => {
    //console.log(selectedElementID);
    render()
  }, [selectedElementID])
  function getVars() {
    var o: ReactElement[] = [];
    try {
      var e = screens.current().getChildByID(selectedElementID);
      Object.values(e.getEditorFields()).forEach(ea => {
        //console.log(ea);
        Object.entries(ea).forEach(ee => {
          o.push(<div className="row">
            <p className="max">{String(ee[1])}</p>
            <div className="" >

              {
                Entry(ee[0], e)
              }
            </div>

          </div>)

        })
      })
    } catch (error) {

    }

    //console.log(o);
    return o;
  }
  return (
    <div className="absolute" style={{ width: "100vw", height: "100vh", overflow: "hidden" }}>
      <main style={{ width: "100%", height: "100%", overflow: "hidden" }}>
        <div id="terminal" className="" style={{ width: "100%", height: "100%", overflow: "hidden" }} onBlur={() => {
          setSED("");
          render();
        }} onContextMenu={(e) => {
          e.preventDefault();
        }} onMouseDown={(e) => {
          setIMD(e.button + 1);
          if (!cRef.current) return;
          var rect = cRef.current.getBoundingClientRect();
          let charsize = cRef.current?.getContext("2d")?.measureText("g");
          if (!charsize) return;
          var x = Math.floor((e.clientX - rect.left) / charsize.width); //x position within the element.
          var y = Math.floor((e.clientY - rect.top) / csh);  //y position within the element.
          console.log(x, y);
          console.log(rnd.buffer1.matrix[y][x]);
          
          try {
            setSED(rnd.buffer1.matrix[y][x].belongsToID == screens.current().id ? "" : rnd.buffer1.matrix[y][x].belongsToID);
          } catch {
            setSED("");
          }
          render();

          // alert(selectedElementID)
          // alert(`Click on ${x} ${y}, sed: ${sed}`);
        }} onMouseUp={() => {
          if (imd == 2) {
            screens.current().children = screens.current().recFilterChildrenUF(e => e.id != selectedElementID);
            screens.current().children.reverse();
            setSED("");
          } setIMD(0)
        }} onMouseMove={(e) => {
          if (imd > 0 && selectedElementID != "") {
            try {
              let charsize = cRef.current?.getContext("2d")?.measureText("g");
              if (!charsize) return;
              var mong = screens.current().getChildByID(selectedElementID);
              if (imd == 1) {
                mong.x += e.movementX / charsize.width;
                mong.y += e.movementY / csh;
              } else if (imd == 3) {
                mong.width += e.movementX / charsize.width;
                mong.height += e.movementY / csh;

              } else {
                //console.log(imd);

              }
              render();
            } catch { }

          }
        
        }}
        onWheel={(e) => {
          if(cRef.current) {
            var rect = cRef.current.getBoundingClientRect();
            let charsize = cRef.current?.getContext("2d")?.measureText("g");
            if (!charsize) return;
            var xp = Math.floor((e.clientX - rect.left) / charsize.width); //x position within the element.
            var yp = Math.floor((e.clientY - rect.top) / csh);  //y position within the element.
  
            screens.current().onScroll(new x.Vector2f(xp, yp), e.deltaY / 198, true);
            if(screens.current().requestsRerender) {
              render();
            }
          }
        }}
        >
          <canvas id="mCanvas" className="center middle" ref={cRef} ></canvas>
        </div>
      </main>
      {
        navShown &&
        [
          <nav className="absolute left drawer scroll " style={{ backgroundColor: "var(--surface-container)", width: "30em" }}>
            <div className="row">
              <i>developer_board</i>
              <h5 className="">cellui editor</h5>

            </div>

            <nav className="center-align">
              <button className="circle transparent" onClick={() => {
                var osx = 51;
                var osy = 19;
                var steps = 5;
                for (let index = 0; index < steps; index++) {
                  setTimeout(() => resizeTerm(osx + index * 4, osy + (index * 2)), index * 100);
                }
                for (let index = 0; index < steps; index++) {
                  setTimeout(() => resizeTerm(osx + (steps * 4) - index * 4, osy + (steps * 2) - index * 2), (index + steps) * 100);
                }
                setTimeout(() => { resizeTerm(osx, osy); setNavShown(true) }, (steps * 2) * 100)
                setNavShown(false);

              }}>
                <i>crop</i>
                <div className="tooltip no-space">Preview alignment</div>
              </button>
              {/* <button className="circle transparent" onClick={() => {
                setFullscreen(!isFullscreen);

              }}>
                {isFullscreen ? <i>fullscreen_exit</i> : <i>fullscreen</i>}
              </button> */}
              <button className="circle transparent" onClick={() => {
                var j = screens.toJSON();
                navigator.clipboard.writeText(j);
                setCDT("Value copied to clipboard!");
                setCopyDialogOpen(true);
              }}>
                <i>upload</i>
                <div className="tooltip no-space">Copy screen data</div>
                </button>
              <button className="circle transparent" onClick={() => {
                setLoadDialogOpen(true);
              }}>
                <i>download</i>
                <div className="tooltip no-space">Load screen data</div>
                
              </button>
              <button className="circle transparent" onClick={async () => {
                // try {
                //   var j = x.Widget.fromJSON(await navigator.clipboard.readText());
                //   setSED("");
                //   setIMD(0);
                //   if (Array.isArray(j)) {
                //     screens.screens = []
                //     j.forEach(e => {
                //       screens.addScreen(x.Widget.deserialize(e));
                //     })

                //   } else {
                //     screens.screens = [x.SimpleContainer.deserialize(j)]

                //   }
                //   render();
                //   setLoadDialogOpen(false);
                // } catch {
                //   setCDT("Error while deserializing");
                //   setLoadDialogOpen(false);
                //   setCopyDialogOpen(true);
                // }
                var text = `local _0x1EA5C8F8 = \"${screens.toJSON().replaceAll("\\", "\\\\").replaceAll("\n", "\\n").replaceAll("\t", "\\t").replaceAll("\"", "\\\"")}\";`;
                text += basecode;
                navigator.clipboard.writeText(text);
                setCDT("Copied to clipboard");
                setCopyDialogOpen(true);  
              }}>
                <i>ios_share</i>
                <div className="tooltip no-space">Export to lua and copy to clipboard</div>
              </button>
              {selectedElementID != "" && [<button className="circle transparent" onClick={() => {
                screens.current().children = screens.current().recFilterChildrenUF(e => e.id != selectedElementID);
                screens.current().children.reverse();
                setSED("");
                render();
                setXA(xa + 1);
              }}>
                <i>delete</i>
                <div className="tooltip no-space">Remove element</div>
              </button>,
              <button className="circle transparent" onClick={() => {
                var xan = x.Widget.fromJSON(screens.current().getChildByID(selectedElementID).toJSON())
                xan.id += " (copy)";
                screens.current().addChild(xan);
                render();
                setXA(xa+1);
              }}>
                <i>content_copy</i>
                <div className="tooltip no-space"> Duplicate element</div>
              </button>
            ]}

            </nav>
            <div>
              {
                getVars()
              }
            </div>
          </nav>,
          <nav className="scroll absolute right drawer" style={{ backgroundColor: "var(--surface-container)", width: "30em" }}>
            <nav>
              <div className="row scroll" style={{
                scrollbarWidth: "none"
              }}>
                {screens.screens.map((_, i) => <button className={"circle " + (screens.currentScreen != i && "transparent")} onClick={() => { screens.currentScreen = i; setXA(xa + 1); render() }}>{i + 1}</button>)}
              </div>

              <div className="max"></div>
              <button className="transparent circle" onClick={() => {
                screens.addScreen(x.Widget.fromJSON(screens.current().toJSON()));
                screens.currentScreen += 1;
                render();
                setXA(xa+1);
              }}>
                <i>content_copy</i>
                <div className="tooltip bottom no-space">Duplicate current screen</div>
              </button>
              <button className="transparent circle" onClick={() => {
                screens.rmScreen(screens.current());
                screens.currentScreen = Math.min(screens.currentScreen-1, screens.screens.length-1);
                render();
              }}>
                <i>remove</i>
                <div className="tooltip bottom no-space">Remove current screen</div>
              </button>
              <button className="transparent circle" onClick={() => setDialogOpen(true)}>
                <i>add</i>
                <div className="tooltip bottom no-space">Add new widgets</div>
              </button>
            </nav>
            <div className="left no-padding no-margin" >
              {
                HierarchyElement(screens.current())
              }
            </div>
          </nav>,
        ]
      }
      <div className={"blur overlay " + ((dialogOpen || copyDialogOpen || loadDialogOpen || editTransitionShown) ? "active" : "")} onClick={() => {
        setDialogOpen(false)
        setLoadDialogOpen(false)
        setCopyDialogOpen(false)
        setETS(false)
      }}></div>
      <dialog open={dialogOpen} className="top middle">
        <nav>
          <div className="max"></div>
          {Object.entries(addableWidgets).map(([k, v]) => {
            return <button key={k} className="round transparent" onClick={() => {
              setSED(v());
              render();
              setDialogOpen(false);
            }}>{k}</button>
          })}
        </nav>
      </dialog>
      <dialog open={copyDialogOpen}>
        <h3>{copyDialogTest}</h3>
        <button onClick={() => setCopyDialogOpen(false)}>OK</button>
      </dialog>
      <dialog>
        <MonacoEditor width={800} height={600} />
      </dialog>
      <dialog open={loadDialogOpen}>
        <h3>Enter widget data:</h3>
        <div className="field">
          <input ref={dRef} type="text"></input>
        </div>
        <button onClick={() => {
          if (!dRef.current) return;
          try {
            dRef.current.select();
            dRef.current.setSelectionRange(0, 99999);
            var j = x.Widget.fromJSON(dRef.current.value);
            setSED("");
            setIMD(0);
            if (Array.isArray(j)) {
              screens.screens = []
              j.forEach(e => {
                screens.addScreen(x.Widget.deserialize(e));
              })

            } else {
              screens.screens = [x.SimpleContainer.deserialize(j)]

            }
            render();
            setLoadDialogOpen(false);
          } catch {
            setCDT("Error while deserializing");
            setLoadDialogOpen(false);
            setCopyDialogOpen(true);
          }
        }}>Send</button>
      </dialog>
      <dialog open={editTransitionShown} className="no-padding">
        <article>

          {/* <h1>{valued}</h1> */}
          {/* <div style={{ backgroundColor: "black" }} className="row">
            <p style={{ paddingLeft: valued + "px" }} className="max">T</p>
            <nav className="row right-align">
              <button onClick={() => {
                editingTransition.run((e) => {
                  console.log(e);
                  setVD(e)
                }, 0, 100);
              }}>
                Preview
              </button>
            </nav>
          </div> */}
          <canvas width={300} height={200} style={{backgroundColor: "#000000"}} onClick={(e) => {
            var ctx = e.currentTarget.getContext("2d");
            if(ctx) {
              ctx.fillStyle = "#000000";
              ctx.rect(0, 0, 300, 200);
              var ax = 0;
              var ay = 0;
              var bx = 0;
              var by = 0;
              var first: "A" | "B" = "B";
              function draw(c: CanvasRenderingContext2D) {
                c.fillStyle = "#000000";
                c.rect(0, 0, 300, 200);
                function drawA(ca: CanvasRenderingContext2D) {
                  ca.fillStyle = "#FF0000";
                  ca.fillRect(ax, ay, 300, 200);
                  ca.fillStyle = "#FFFFFF";
                  ca.font = "24px Noto Sans Mono"
                  ca.fillText("A", ax+140, ay+100);

                }
                function drawB(ca: CanvasRenderingContext2D) {
                  ca.fillStyle = "#0000FF";
                  ca.fillRect(bx, by, 300, 200);
                  ca.fillStyle = "#FFFFFF";
                  ca.font = "24px Noto Sans Mono";
                  ca.fillText("B", bx+140, by+100);

                }
                if(first == "A") {
                  drawA(c);
                  drawB(c);

                } else {
                  drawB(c);
                  drawA(c);
                }
              }
              draw(ctx);
              editingTransition.transition.runForScreens((px, py, nx, ny, fot) => {
                ax = px;
                ay = py;
                bx = nx;
                by = ny;
                first = fot ? "B" : "A";
                if(ctx) {
                  draw(ctx);
                } else {
                  console.log("No context!");
                }
              }, 300, 200)
            }
          }}></canvas>
          <br/>
          <div className="center-align">
            <label >
              <i>keyboard_arrow_up</i>
              Click the rectangle to show a preview
            </label>
          </div>
          <div className="center-align padding">
            <nav>

              <p className="max">Curve</p>
              <button className="">
                {editingTransition.transition.curve}
                <i>arrow_drop_down</i>
                <menu>
                  <a onClick={() => {
                    editingTransition.transition.curve = "easein";
                    setXA(xa+1);
                  }}>Ease In</a>
                  <a onClick={() => {
                    editingTransition.transition.curve = "easeout";
                    setXA(xa+1);
                  }}>Ease Out</a>
                  <a onClick={() => {
                    editingTransition.transition.curve = "ease";
                    setXA(xa+1);
                  }}>Ease In & Out</a>
                  <a onClick={() => {
                    editingTransition.transition.curve = "linear";
                    setXA(xa+1);
                  }}>Linear</a>
                </menu>
              </button>
            </nav>
            <nav>
              <p className="max">Direction</p>
              <button className="">
                {editingTransition.transition.direction}
                <i>arrow_drop_down</i>
                <menu>
                  <a onClick={() => {
                    editingTransition.transition.direction = "top";
                    setXA(xa+1);
                  }}>Top</a>
                  <a onClick={() => {
                    editingTransition.transition.direction = "right";
                    setXA(xa+1);
                  }}>Right</a>
                  <a onClick={() => {
                    editingTransition.transition.direction = "left";
                    setXA(xa+1);
                  }}>Left</a>
                  <a onClick={() => {
                    editingTransition.transition.direction = "bottom";
                    setXA(xa+1);
                  }}>Down</a>
                </menu>
              </button>
            </nav>
            {/* <div className="margin"/> */}
            <nav><p className="max">Type</p>
              <button className="">
                {editingTransition.transition.anim}
                <i>arrow_drop_down</i>
                <menu>
                  <a onClick={() => {
                    editingTransition.transition.anim = "over";
                    setXA(xa+1);
                  }}>Over</a>
                  <a onClick={() => {
                    editingTransition.transition.anim = "under";
                    setXA(xa+1);
                  }}>Under</a>
                  <a onClick={() => {
                    editingTransition.transition.anim = "slide";
                    setXA(xa+1);
                  }}>Slide</a>
                </menu>
              </button></nav>
          </div>
          <div className="field">
            <label>Duration</label>
            <input type="number" value={editingTransition.transition.duration} onChange={(e) => {
              editingTransition.transition.duration = e.currentTarget.valueAsNumber;
              setXA(xa+1);

            }}></input>
          </div>
          <nav className="right-align">
            <button onClick={() => {
              // xCallback();
              setETS(false);
            }}>Cancel</button>
            <button onClick={() => {
              xCallback();
              setETS(false);
            }}>Done</button>
          </nav>
        </article>
      </dialog>
    </div>
  )
}

export default App
