components {
  id: "controller"
  component: "/main/actor/controllers/player.script"
}
components {
  id: "hitbox_factory"
  component: "/main/actor/hitboxes/hitbox_factory.factory"
}
embedded_components {
  id: "bounding_box"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_KINEMATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"player_bound\"\n"
  "mask: \"default\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 3\n"
  "    id: \"Box\"\n"
  "  }\n"
  "  data: 7.5\n"
  "  data: 30.0\n"
  "  data: 10.0\n"
  "}\n"
  ""
}
