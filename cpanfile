requires 'perl', '5.008001';
requires 'App::cpanminus';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
