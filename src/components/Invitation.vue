<template>
  <div class="wedding-invitation" :class="{ 'invitation-bounce':canOpen }">
    <div class="invitation-container" :class="{ 'invitation-down':isOpening }">
      <div class="invitation-cover">
        <div class="cover-content" :class="{'invitation-up':isOpening}">
          <div class="content-inside">
              <div v-for="(item,index) in images"
                   :key="index"
                   v-show="index+1 == currentImage + 1">
                  <transition name="fade" @before-enter='beforeEnter' @after-leave="afterLeave">
                  <img :src="item.src" v-show="showImage">
                  </transition>
              </div>

            <p>我们结婚啦！</p>
            <p><b>谢成炫 & 黄梦祎 </b></p>
            <div v-if="location == 'FUMANLOU'">
              <p >时间: 2019年8月24日12时</p>
              <p>地点: 适中镇中颜小区<b>福满楼</b></p>
            </div>
            <div v-if="location == 'ZHONGYUAN'">
            <p >时间：2019年8月26日12时</p>
              <p>地点：龙岩市<b>中元大酒店</b></p>
            </div>
            <label>恭请光临: </label>
            <select name="public-choice" v-model="couponSelected" @change="getCouponSelected">
              <option :value="coupon.id" v-for="coupon in couponList" :key="coupon.id" >{{coupon.name}}</option>
            </select>
            <input v-show="couponSelected != 'NOATTEND'"
                   class="content-inside-input"
                   placeholder="您的姓名"
                   v-model="name"
                   @focus="isFocused = true"
            >
            <input v-show="couponSelected != 'NOATTEND'"
                   class="content-inside-input"
                   v-model="wechatId"
                   placeholder="请输入您的联系方式"
                   @focus="isFocused = true"
            >
            <input
              class="content-inside-input"
              placeholder="轻触写下祝福，按回车发送"
              @blur="isFocused = false, hasEntered = false"
              v-model="wish"
              ref="wishInput"
            >
            <button type="button"
                    v-bind:disabled="!wish"
                    v-on:click="sendBarrage()"
                    v-show="couponSelected == 'NOATTEND'"
                    style="float: right">发送祝福</button>
            <button type="button"
                    v-bind:disabled="!name || !wechatId"
                    v-on:click="sendBarrage()"
                    v-show="couponSelected != 'NOATTEND'"
                    style="float: right">发送预约</button>

          </div>
        </div>
        <div class="cover-inside-left" :class="{'opening':isOpening}"></div>
        <div class="cover-inside-right" :class="{'opening':isOpening}"></div>
        <img class="cover-inside-seal" src="../images/seal.png" @click="openInvitation" :class="{'invitation-flight':isOpening}">
      </div>
    </div>
  </div>
</template>

<script>
/* eslint-disable */
import utils from '../utils/utils'
let location=utils.getUrlKey('location');
location = location?location:'FUMANLOU';

export default {
  props: ['canOpen'],
  data() {
    return {
      images: [{src:require('../images/A1.jpg'),id:1},
          {src:require('../images/A2.jpg'),id:2},
          {src:require('../images/A3.jpg'),id:3},
          {src:require('../images/A4.jpg'),id:4},
          {src:require('../images/A5.jpg'),id:5},
          {src:require('../images/A6.jpg'),id:6},
          {src:require('../images/A7.jpg'),id:7},
          {src:require('../images/A8.jpg'),id:8},
          {src:require('../images/A9.jpg'),id:9}],
      isOpening: false,
      wish: '',
      wechatId: '',
      name: '',
      isFocused: false,
      hasEntered: false,
      couponList: [{name:'8月24日福满楼酒家',id:'FUMANLOU'},{name:'8月26日中元大酒店',id:'ZHONGYUAN'},{name:'无法出席',id:'NOATTEND'}],
      couponSelected: location?location:'FUMANLOU',
      location: location,
      currentImage:0,
      showImage:false
    }
  },
  methods: {
    // 打开邀请函
    openInvitation(){
      this.isOpening = true
      setTimeout(this.showImage=true,0);
    },
    beforeEnter(){

        var show = this.show;
        setTimeout(()=>{
            show(false);
        },2500)
    },
    afterLeave(){

        this.change();
        this.show(true);
    },
    show(t){
        this.showImage = t;
    },
    change(){
        this.currentImage = (this.currentImage+1)%this.images.length;

    },
    rolling(){
        var change = this.change;
        var rolling = this.rolling;
        setTimeout(() => {
            change();
            rolling();
        }, 6000)
    },
    // 发送弹幕
    sendBarrage(){
      this.$nextTick(() => {
        this.hasEntered = true;
        if (!this.wish) {
          return
        }
        this.isOpening = false;
        this.$refs.wishInput.blur();
        this.reply();
        setTimeout(() => {
          this.$emit('sendBarrage', this.wish)
        }, 660)
      })
    },
    getCouponSelected(){
        this.location = this.couponSelected;

    },
      sendComment(id){
          axios
              .put('/rest/comment',{guestId:id,comment:this.wish})
              .then(function (response) {
                  let data = response.data;
                  for(var i in data){
                      barrage.push(data[i].comment)
                  }

              })
              .catch(function (error) { // 请求失败处理

              });
      },
      reply(){
        let name = this.name;
        let wechaId = this.wechatId;
        let couponSelected = this.couponSelected;
        var sendComment = this.sendComment;
        if(!name || !wechaId){
            sendComment('1001')
            return;
        }
          axios
              .put('/rest/guest',{
                  "name":name,
                  "wechatId": wechaId,
                  "attend": couponSelected
              })
              .then(function (response) {
                  sendComment(response.data.retMsg);
              })
              .catch(function (error) { // 请求失败处理

              });
      }
  }
}
</script>

<style lang="less">
  .wedding-invitation{
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    padding: 30px 20px;
    padding-top: 60px;
    z-index: 4;
    transform: scale(0.05);
    -webkit-transform: scale(0.05);
    opacity: 0;
    transition: transform 0.8s cubic-bezier(.26,1.84,.39,.61), opacity 0.5s linear;
    -webkit-transition: -webkit-transform 0.8s cubic-bezier(.26,1.84,.39,.61), opacity 0.5s linear;
    background-size: 100%;
    overflow: hidden;
    &.invitation-bounce{
      opacity: 1;
      transform: scale(1);
      -webkit-transform: scale(1);
    }
    .invitation-container{
      position: relative;
      width: 100%;
      height: 100%;
      transition: transform 0.6s cubic-bezier(0.4, 0, 1, 1);
      -webkit-transition: -webkit-transform 0.6s cubic-bezier(0.4, 0, 1, 1);
      &.invitation-down{
        transform: translateY(20px);
        -webkit-transform: translateY(20px);
      }
      .invitation-cover{
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: #D65047;
        border-radius: 10px;
        perspective: 500px;
        box-shadow: 0 0 20px 2px rgba(0, 0, 0, 0.15);
        .cover-content{
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          padding: 10px 20px;
          transition: transform 0.6s cubic-bezier(0.4, 0, 1, 1);
          -webkit-transition: -webkit-transform 0.6s cubic-bezier(0.4, 0, 1, 1);
          &.invitation-up{
            transform: translateY(-60px);
            -webkit-transform: translateY(-60px);
          }
          .content-inside{
            height: 100%;
            padding: 20px;
            color: #a9895d;
            background-color: #FFF1DE;
            text-align: center;
            overflow: auto;
            .content-inside-photo{
              width: 100%;
              margin-bottom: 10px;
              padding: 5px;
              border: 1px solid #f7debb;
            }
            p{
              margin-top: 0;
              margin-bottom: 5px;
            }
            .content-inside-input{
              width: 100%;
              height: 35px;
              margin-top: 10px;
              outline: none;
              border: none;
              border-bottom: 1px solid #f7debb;
              color: #a9895d;
              background: transparent;
              &::-webkit-input-placeholder { color: #E8D1B1;font-size: 12px; }
              &::-moz-placeholder { color: #E8D1B1;font-size: 12px; }
              &:-ms-input-placeholder { color: #E8D1B1;font-size: 12px; }
              &:-moz-placeholder { color: #E8D1B1;font-size: 12px; }
            }
          }
        }
        .cover-inside-left{
          position: absolute;
          left: 0;
          top: 0;
          width: 70%;
          height: 100%;
          border-radius: 10px;
          background-color: #D65047;
          box-shadow: 5px 0 10px rgba(0,0,0,0.2);
          z-index: 6;
          transition: transform 0.5s;
          -webkit-transition: -webkit-transform 0.5s;
          transform-origin: 0 50%;
          -webkit-transform-origin: 0 50%;
          &.opening{
            transform: rotate3d(0,1,0,-140deg);
            -webkit-transform: rotate3d(0,1,0,-140deg);
          }
        }
        .cover-inside-right{
          position: absolute;
          right: 0;
          top: 0;
          width: 40%;
          height: 100%;
          border-radius: 10px;
          background-color: #D65047;
          box-shadow: -5px 0 10px rgba(0,0,0,0.2);
          z-index: 5;
          transition: transform 0.5s;
          -webkit-transition: -webkit-transform 0.5s;
          transform-origin: 100% 50%;
          -webkit-transform-origin: 100% 50%;
          &.opening{
            transform: rotate3d(0,1,0,140deg);
            -webkit-transform: rotate3d(0,1,0,140deg);
          }
        }
        .cover-inside-seal{
          position: absolute;
          left: 70%;
          bottom: 100px;
          width: 80px;
          height: 80px;
          margin-left: -40px;
          z-index: 7;
          transform-origin: 50% 50%;
          -webkit-transform-origin: 50% 50%;
          transition: all 0.8s cubic-bezier(0.4, 0, 1, 1);
          -webkit-transition: all 0.8s cubic-bezier(0.4, 0, 1, 1);
          &.invitation-flight{
            opacity: 0;
          }
        }
      }
    }
  }

  .fade-enter-active, .fade-leave-active {
      transition: opacity 2s
  }
  .fade-enter, .fade-leave-to /* .fade-leave-active, 2.1.8 版本以下 */ {
      opacity: 0
  }


</style>
