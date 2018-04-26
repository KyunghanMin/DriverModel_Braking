%���� ��ǥ�� �Է�

Radius = [];
RoadPos= 1450:1900;
for i  = RoadPos(1):RoadPos(end)
    x1=X(i);    
    y1=Y(i);
    x2=X(i+1);   
    y2=Y(i+1);
    
    
    x3=X(i+2);
    
    y3=Y(i+2);
    
    
    
    %�� ���� �̵�м��� ���⸦ �Է�
    
    d1=(x2-x1)/(y2-y1);
    
    d2=(x3-x2)/(y3-y2);
    
    
    
    %���� ������ ����
    
    cx=((y3-y1)+(x2+x3)*d2-(x1+x2)*d1)/(2*(d2-d1));
    
    cy=-d1*(cx-(x1+x2)/2)+(y1+y2)/2;
    
    
    
    %���� �������� ����
    
    r=sqrt((x1-cx)^2+(y1-cy)^2);
    input=[x1 y1; x2 y2; x3 y3];
    [R,xyrc] = fit_circle_through_3_points(input);
    Radius=[Radius R];
    
    
end
figure(99)
plot(RoadPos,Radius);
ylim([0,100]);