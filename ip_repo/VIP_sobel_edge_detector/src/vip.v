//****************************************Copyright (c)***********************************//
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡFPGA & STM32���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           vip
// Last modified Date:  2019/03/22 16:33:40
// Last Version:        V1.0
// Descriptions:        ����ͼ����ģ���װ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/03/22 16:33:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module Vip(
    //module clock
    input           clk            ,    // ʱ���ź�
    input           rst_n          ,    // ��λ�źţ�����Ч��

    //ͼ����ǰ�����ݽӿ�
    input           pre_frame_vsync,
    input           per_frame_href,
    input           per_frame_clken   ,
    input    [23:0] per_frame_data        ,

    //ͼ���������ݽӿ�
    output          post_frame_vsync,   // ��ͬ���ź�
    output          post_frame_href ,   // ��ͬ���ź�
    output          post_frame_clken,   // ��������ʹ��
    output   [23:0] post_frame_data     // RGB888��ɫ����
);

parameter  SOBEL_THRESHOLD = 128; //sobel��ֵ

wire                  ycbcb_vsync;
wire                  ycbcbr_clken;
wire                  ycbcr_valid;
wire   [ 7:0]         gray_data;

wire                  post_img_bit;
//*****************************************************
//**                    main code
//*****************************************************

assign  post_frame_data = {24{~post_img_bit}};

//RGBתYCbCrģ��
//rgbתycbcrģ��
rgb2ycbcr  u_rgb2ycbcr(
    .clk          (clk),
    .rst_n        (rst_n),
                  
    .rgb_vsync    (pre_frame_vsync),
    .rgb_clken    (per_frame_clken),
    .rgb_valid    (per_frame_href),
    .rgb_data     (per_frame_data),
                  
                  
    .ycbcb_vsync  (ycbcb_vsync),
    .ycbcbr_clken (ycbcbr_clken),
    .ycbcr_valid  (ycbcr_valid),
    .gray_data    (gray_data)
);

vip_sobel_edge_detector
    #(
    .SOBEL_THRESHOLD  (SOBEL_THRESHOLD)    //sobel��ֵ
    )
u_vip_sobel_edge_detector(
    .clk   (clk),
    .rst_n (rst_n),
    
    //����ǰ����
    .per_frame_vsync (ycbcb_vsync ),     //����ǰ֡��Ч�ź�
    .per_frame_href  (ycbcr_valid ),     //����ǰ����Ч�ź�
    .per_frame_clken (ycbcbr_clken),     //����ǰͼ��ʹ���ź�
    .per_img_y       (gray_data   ),     //����ǰ����Ҷ�����
    
    //����������
    .post_frame_vsync (post_frame_vsync),    //�����֡��Ч�ź�
    .post_frame_href  (post_frame_href ),    //���������Ч�ź�
    .post_frame_clken (post_frame_clken),    //���ʹ���ź�
    .post_img_bit     (post_img_bit    )     //�������
        
);
endmodule
