requires 'App::cpanminus';
requires 'File::Path';
requires 'File::Temp';
requires 'perl', '5.008001';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'Test::More', '0.98';
};
