@ar=(1,2,3);
$t{k}=\@ar;
@ar2=@{$t{k}};
#print join(',',@ar2);
print join(',',@{$t{k}});
exit;
@ar=view_synonim('���� �������� ����������������� ����������
 <a href=http://www.headcall.ru/>������ ������������ {������|��������}
 {����������|�����-����������} headcall.ru</a>',0,0);
print $ar[0];
view_synonim('���������� � ����� ����� �� ����� ������ ����� �� 
��������� <a href=http://www.headcall.ru/>������� ������������ 
{��������|������} {����������|�����-����������} headcall.ru</a>');
view_synonim('������������ ����� ��������� �� ������ ���������� 
<a href=http://www.headcall.ru/>�� ����� {��������|������} 
{����������|�����-����������} headcall.ru</a>');
view_synonim('��� ����� �������� � ���� ������ 
<a href=http://www.headcall.ru/>{������|���������������} {��������|������} 
{����������|�����-����������} headcall.ru</a>');
view_synonim('�������� � ������������ ����� ������������ 
<a href=http://www.headcall.ru/>� {��������|�����������} 
{��������|������} {����������|�����-����������} headcall.ru</a>');
view_synonim('����� ������� � ����� ��������������� ���������� 
<a href=http://www.headcall.ru/>������� ������������ {������|��������} 
����������|�����-����������} headcall.ru</a>');
sub view_synonim{
   my $text=shift;
   my @val=@_;
   my ($tmp,$rnd,@res);#res-����� ������ ����������� ���� �������
   while($text=~/\{([^\|]+)\|([^\|]+)\}/){
      $rnd=($#val!=-1?shift @val:sprintf("%.0f",rand()));
      $tmp=($1,$2)[$rnd];
      $text=~s/\{[^\|]+\|[^\|]+\}/$tmp/;
      push(@res,$rnd);
   }
   return ($text,@res);
}


