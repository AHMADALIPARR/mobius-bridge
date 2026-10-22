import Lake
open Lake DSL

package «mobius» where
  -- add package configuration options here

lean_lib «Mobius» where
  -- add library configuration options here

@[default_target]
lean_exe «mobius» where
  root := `Main
