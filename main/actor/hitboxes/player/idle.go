components {
  id: "actor_sprite"
  component: "/main/actor/sprites/actor_sprite.sprite"
}
embedded_components {
  id: "hurt1"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_TRIGGER\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"player_hitbox\"\n"
  "mask: \"enemy_hurtbox\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 1.0\n"
  "      y: 17.0\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 3\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: -5.0\n"
  "      y: -8.0\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 3\n"
  "    count: 3\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: -9.0\n"
  "      y: -24.0\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 6\n"
  "    count: 3\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 8.0\n"
  "      y: -9.0\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 9\n"
  "    count: 3\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 7.0\n"
  "      y: -24.0\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 12\n"
  "    count: 3\n"
  "  }\n"
  "  data: 7.0\n"
  "  data: 16.5\n"
  "  data: 10.0\n"
  "  data: 5.5\n"
  "  data: 10.5\n"
  "  data: 10.0\n"
  "  data: 6.5\n"
  "  data: 6.5\n"
  "  data: 10.0\n"
  "  data: 6.0\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 7.5\n"
  "  data: 6.0\n"
  "  data: 10.0\n"
  "}\n"
  ""
}
