import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bonfire/bonfire.dart';

import '../sprite_sheet/sprite_sheet_player.dart';
import 'orc.dart';

double tileSize = 20.0;

class HumanPlayer extends SimplePlayer
    with Lighting, ObjectCollision, UseBarLife {
  HumanPlayer(Vector2 position)
      : super(
          position: position,
          animation: SimpleDirectionAnimation(
            idleLeft: SpriteSheetPlayer.idleBottomLeft,
            idleRight: SpriteSheetPlayer.idleBottomRight,
            idleUp: SpriteSheetPlayer.idleTopRight,
            idleUpLeft: SpriteSheetPlayer.idleTopLeft,
            idleUpRight: SpriteSheetPlayer.idleTopRight,
            runLeft: SpriteSheetPlayer.runBottomLeft,
            runRight: SpriteSheetPlayer.runBottomRight,
            runUpLeft: SpriteSheetPlayer.runTopLeft,
            runUpRight: SpriteSheetPlayer.runTopRight,
            runDownLeft: SpriteSheetPlayer.runBottomLeft,
            runDownRight: SpriteSheetPlayer.runBottomRight,
          ),
          speed: maxSpeed,
          life: 1000,
          size: Vector2.all(tileSize * 2.9),
        ) {
    /// 发光
    setupLighting(
      LightingConfig(
        radius: width / 2,
        blurBorder: width / 2,
        color: Colors.transparent,
      ),
    );

    /// 碰撞
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(
              size.x * 0.2,
              size.y * 0.15,
            ),
            align: Vector2(tileSize * 1.15, tileSize * 1.5),
          ),
        ],
      ),
    );

    /// 生命条
    setupBarLife(
      size: Vector2(tileSize * 1.5, tileSize / 5),
      barLifePosition: BarLifePorition.top,
      showLifeText: false,
      margin: 0,
      borderWidth: 2,
      borderColor: Colors.white.withOpacity(0.5),
      borderRadius: BorderRadius.circular(2),
      offset: Vector2(0, tileSize * 0.5),
    );
  }

  static double maxSpeed = tileSize * 4;

  bool lockMove = false;

  /// 渲染
  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  /// 碰撞触发
  @override
  bool onCollision(GameComponent component, bool active) {
    bool active = true;

    /// 碰撞 Orc 不发生碰撞
    if (component is Orc) {
      print('碰撞 Orc');
      active = false;
    }
    return active;
  }

  /// 操纵手柄操作控制
  @override
  void joystickAction(JoystickActionEvent event) {
    /// 死亡 || 锁住移动
    if (isDead || lockMove) return;

    /// 攻击
    if ((event.id == LogicalKeyboardKey.space.keyId ||
            event.id == LogicalKeyboardKey.select.keyId ||
            event.id == 1) &&
        event.event == ActionEvent.DOWN) {
      /// 攻击动画
      _addAttackAnimation();

      /// 攻击范围
      simpleAttackMelee(
        damage: 10,
        size: Vector2.all(tileSize * 1.5),
        withPush: false,
      );
    }
    super.joystickAction(event);
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (lockMove || isDead) {
      return;
    }
    speed = maxSpeed * event.intensity;
    super.joystickChangeDirectional(event);
  }

  /// 受伤触发
  @override
  void receiveDamage(AttackFromEnum attacker, double damage, dynamic from) {
    if (!isDead) {
      showDamage(
        damage,
        initVelocityTop: -2,
        config: TextStyle(color: Colors.white, fontSize: tileSize / 2),
      );
      // lockMove = true;
      /// 屏幕变红
      // gameRef.lighting
      //     ?.animateToColor(const Color(0xFF630000).withOpacity(0.7));

      // idle();
      // _addDamageAnimation(() {
      //   lockMove = false;
      //   gameRef.lighting?.animateToColor(Colors.black.withOpacity(0.7));
      // });
    }
    super.receiveDamage(attacker, damage, from);
  }

  @override
  void die() {
    animation?.playOnce(
      SpriteSheetPlayer.getDie(),
      onFinish: () {
        removeFromParent();
      },
      runToTheEnd: true,
    );
    super.die();
  }

  /// 攻击动画
  void _addAttackAnimation() {
    Future<SpriteAnimation> newAnimation;
    switch (lastDirection) {
      case Direction.left:
        newAnimation = SpriteSheetPlayer.getAttackBottomLeft();
      case Direction.right:
        newAnimation = SpriteSheetPlayer.getAttackBottomRight();
      case Direction.up:
        if (lastDirectionHorizontal == Direction.left) {
          newAnimation = SpriteSheetPlayer.getAttackTopLeft();
        } else {
          newAnimation = SpriteSheetPlayer.getAttackTopRight();
        }
      case Direction.down:
        if (lastDirectionHorizontal == Direction.left) {
          newAnimation = SpriteSheetPlayer.getAttackBottomLeft();
        } else {
          newAnimation = SpriteSheetPlayer.getAttackBottomRight();
        }
      case Direction.upLeft:
        newAnimation = SpriteSheetPlayer.getAttackTopLeft();
      case Direction.upRight:
        newAnimation = SpriteSheetPlayer.getAttackTopRight();
      case Direction.downLeft:
        newAnimation = SpriteSheetPlayer.getAttackBottomLeft();
      case Direction.downRight:
        newAnimation = SpriteSheetPlayer.getAttackBottomRight();
    }
    animation?.playOnce(newAnimation);
  }

  /// 受伤动画
  // void _addDamageAnimation(VoidCallback onFinish) {
  //   Future<SpriteAnimation> newAnimation;
  //   switch (lastDirection) {
  //     case Direction.left:
  //       newAnimation = SpriteSheetPlayer.getDamageBottomLeft();
  //     case Direction.right:
  //       newAnimation = SpriteSheetPlayer.getDamageBottomRight();
  //     case Direction.up:
  //       if (lastDirectionHorizontal == Direction.left) {
  //         newAnimation = SpriteSheetPlayer.getDamageTopLeft();
  //       } else {
  //         newAnimation = SpriteSheetPlayer.getDamageTopRight();
  //       }
  //     case Direction.down:
  //       if (lastDirectionHorizontal == Direction.left) {
  //         newAnimation = SpriteSheetPlayer.getDamageBottomLeft();
  //       } else {
  //         newAnimation = SpriteSheetPlayer.getDamageBottomRight();
  //       }
  //     case Direction.upLeft:
  //       newAnimation = SpriteSheetPlayer.getDamageTopLeft();
  //     case Direction.upRight:
  //       newAnimation = SpriteSheetPlayer.getDamageTopRight();
  //     case Direction.downLeft:
  //       newAnimation = SpriteSheetPlayer.getDamageBottomLeft();
  //     case Direction.downRight:
  //       newAnimation = SpriteSheetPlayer.getDamageBottomRight();
  //   }
  //   animation?.playOnce(
  //     newAnimation,
  //     runToTheEnd: true,
  //     onFinish: onFinish,
  //   );
  // }
}
