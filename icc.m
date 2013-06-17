function [] = icc ()
    %% LOAD CONFIGURATION %%
    
    % get experiment directory
    base_dir = [ uigetdir([], 'Select experiment directory') '/' ];
    
    % load the tab-delimited configuration file
    config = ReadStructsFromText([base_dir 'config.txt']);
    
    disp(sprintf('You are running %s\n\n',get_config('StudyName')));

    %% SETUP EXPERIMENT AND SET SESSION VARIABLES %%
    
    % tell matlab to shut up, and seed it's random numbers
    warning('off','all');
    random_seed = sum(clock);
    rand('twister',random_seed);

    [ year, month, day, hour, minute, sec ] = datevec(now);
    start_time = [num2str(year) '-' num2str(month) '-' num2str(day) ' ' num2str(hour) ':' num2str(minute) ':' num2str(sec) ];
    
    % get subject code
    experimenter = input('Enter your (experimenter) name: ','s');
    subject_code = input('Enter subject code: ', 's');
    subject_sex = input('Enter subject sex (M/F):  ', 's');
    subject_age = input('Enter subject age (in months; e.g., X.XX): ', 's');
    
    % begin logging now, because we have the subject_code
    create_log_file();
    log_msg(sprintf('Set base dir: %s',base_dir));
    log_msg('Loaded config file');
    log_msg(sprintf('Study name: %s',get_config('StudyName')));
    log_msg(sprintf('Random seed set as %s via "twister"',num2str(random_seed)));
    log_msg(sprintf('Start time: %s',start_time));
    log_msg(sprintf('Experimenter: %s',experimenter));
    log_msg(sprintf('Subject Code: %s',subject_code));
    log_msg(sprintf('Subject Sex: %s',subject_sex));
    log_msg(sprintf('Subject Age: %s',subject_age));

    %% ASSIGN TO CONDITIONS %%
    
    % load/generate counterbalance condition tracker
    if (isempty(dir([base_dir 'counterbalancer.txt'])) == 0)
        counterbalancer = ReadStructsFromText([base_dir 'counterbalancer.txt']);
    else
        % create empty data structure for results
        counterbalancer = struct('subject_code',{},'fam_category',{},'fam_first_side',{},'novelty_side_at_test',{});
    end
    
    % randomly assign to category
    fam_category = randi(2);
    
        % counterbalance it?
        if (get_config('CounterBalance') == 1 && length(counterbalancer) > 1)
            % counterbalancing is possible
            if (mode([counterbalancer.fam_category]) == fam_category)
                log_msg('Counterbalancing fam_category');
                if (fam_category == 2)
                    fam_category = 1;
                else
                    fam_category = 2;
                end
            end
        end

    % randomly assign to first side presentation
    % 1 == L, 2 == R
    fam_first_side = randi(2);
    
        % counterbalance it?
        if (get_config('CounterBalance') == 1 && length(counterbalancer) > 1)
            % counterbalancing is possible
            if (mode([counterbalancer.fam_first_side]) == fam_first_side)
                log_msg('Counterbalancing fam_first_side');
                if (fam_first_side == 2)
                    fam_first_side = 1;
                else
                    fam_first_side = 2;
                end
            end
        end

    % randomly assign to novelty side at test
    % 1 == L, 2 == R
    novelty_side_at_test = randi(2);
    
        % counterbalance it?
        if (get_config('CounterBalance') == 1 && length(counterbalancer) > 1)
            % counterbalancing is possible
            % we want to add a little bit more randomness to this
            if (mode([counterbalancer.novelty_side_at_test]) == novelty_side_at_test && round(rand(1)) == 1)
                log_msg('Counterbalancing novelty_side_at_test');
                if (novelty_side_at_test == 2)
                    novelty_side_at_test = 1;
                else
                    novelty_side_at_test = 2;
                end
            end
        end
        
    % update counterbalancer file with new information
    new_counterbalancer_line = length(counterbalancer) + 1;
    counterbalancer(new_counterbalancer_line).subject_code = subject_code;
    counterbalancer(new_counterbalancer_line).fam_category = fam_category;
    counterbalancer(new_counterbalancer_line).fam_first_side = fam_first_side;
    counterbalancer(new_counterbalancer_line).novelty_side_at_test = novelty_side_at_test;
    
    %% LOAD STIMULI %%

    % load in familiarization stimuli
    cd(base_dir);

    category1 = get_config('Category1Name');
    category2 = get_config('Category2Name');
    
    log_msg(sprintf('Category 1 name: %s',category1));
    log_msg(sprintf('Category 2 name: %s',category2));

    if (fam_category == 1)
        fam_category_name = category1;
        novel_category_name = category2;
    else
        fam_category_name = category2;
        novel_category_name = category1;
    end

    if (fam_first_side == 1)
        fam_first_side_name = 'L';
    else
        fam_first_side_name = 'R';
    end

    if (novelty_side_at_test == 1)
        novelty_side_at_test_name = 'L';
    else
        novelty_side_at_test_name = 'R';
    end
    
    % gather images
    stimuli = dir(['./' get_config('StimuliFolder')]);
    
    log_msg('Looking for fam images...');

    % get familiarization images
    matching_fam = find(cellfun(@(x) ~isempty(regexp(x, [fam_category_name '-[0-9].*'])), {stimuli.name}));
    fam_images = {stimuli(matching_fam).name};
    
    log_msg(sprintf('Retrieved %s familiarization images for the category',length(fam_images)));

    % display the randomly assigned order information
    disp(sprintf('\n\nFamiliarization Category: %s', upper(fam_category_name)));
    disp(sprintf('Familiarization First Side: %s', fam_first_side_name));
    disp(sprintf('Novelty Side at Test: %s', novelty_side_at_test_name));

    if (novelty_side_at_test == 1)
        order_code = upper([fam_category_name(1) fam_first_side_name '-' novel_category_name(1) fam_category_name(1)]);
    else
        order_code = upper([fam_category_name(1) fam_first_side_name '-' fam_category_name(1) novel_category_name(1)]);
    end
    
    log_msg(sprintf('Order code: %s',order_code));

    disp(sprintf('\n\nFinal Order Code: %s', order_code));

    % wait for experimenter to press Enter to begin
    disp(upper(sprintf('\n\nPress any key to launch the experiment window\n\n')));
    KbWait([], 2);
    
    log_msg('Experimenter has launched the experiment window');

    %% SETUP SCREEN %%

    if (get_config('DebugMode') == 1)
        % skip sync tests for faster load
        Screen('Preference','SkipSyncTests', 1);
        log_msg('Running in DebugMode');
    else
        % shut up
        Screen('Preference', 'SuppressAllWarnings', 1);
        log_msg('Not running in DebugMode');
    end

    % disable the keyboard
    ListenChar(2);

    % create window
    wind = Screen('OpenWindow',max(Screen('Screens')));
    
    log_msg(sprintf('Using screen #',num2str(max(Screen('Screens')))));
    
    % initialize sound driver
    log_msg('Initializing sound driver...');
    InitializePsychSound;
    log_msg('Sound driver initialized.');
    
    % we may want PNG images
    Screen('BlendFunction', wind, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % grab height and width of screen
    res = Screen('Resolution',max(Screen('Screens')));
    sheight = res.height;
    swidth = res.width;
    winRect = Screen('Rect', wind);
    
    log_msg(sprintf('Screen resolution is %s by %s',num2str(swidth),num2str(sheight)));

    % wait to begin experiment
    Screen('TextFont', wind, 'Helvetica');
    Screen('TextSize', wind, 25);
    DrawFormattedText(wind, 'Press any key to begin!', 'center', 'center');
    Screen('Flip', wind);

    KbWait([], 2);
    
    log_msg('Experimenter has begun experiment.');

    %% RUN EXPERIMENT TRIALS %%

    % attract initial attention
    attention_getter();

    % CALIBRATION
    if (~isempty(get_config('CalibrationVideo')))
        log_msg(sprintf('Showing calibration video (%s)',get_config('CalibrationVideo')));
        % show calibration
        play_movie(get_config('CalibrationVideo'));
    end
    
    % attract attention before preference assessment
    attention_getter();

    %% PRE-TRIAL PREFERENCE ASSESSMENT %%
    if (get_config('AssessPreference') == 1)
        log_msg('Assessing a prior preferences');
        matching_image = find(cellfun(@(x) ~isempty(regexp(x, [fam_category_name '-test-1.*'])), {stimuli.name}));
        familiar_image = stimuli(matching_image).name;
        
        matching_image = find(cellfun(@(x) ~isempty(regexp(x, [novel_category_name '-test-1.*'])), {stimuli.name}));
        novel_image = stimuli(matching_image).name;
        
        if (novelty_side_at_test == 1)
            [ pref_novel pref_fam ] = test_images(novel_image,familiar_image);
        else
            [ pref_fam pref_novel ] = test_images(familiar_image,novel_image);
        end
        
        log_msg(sprintf('Pre-trial Novelty Preference: %s', num2str((pref_novel / (pref_novel + pref_fam)))));
    end
    
    % PRE-TRIAL VIDEO EXPOSURE
    if (~isempty(get_config('PreVideo')))
        log_msg(sprintf('Showing pre-trial exposure video (%s)',get_config('PreVideo')));
        % show calibration
        play_movie(get_config('PreVideo'));
    end

    % FAMILIARIZATION

    % random order the images
    fam_images = fam_images(randperm(length(fam_images)));

    total_fam_looking = 0;
    total_looking = 0;
    for i = 1:length(fam_images)
        % show the image
        % if they failed >5s to look on the last trial, use the attention getter
        
        log_msg(sprintf('Showing familiarization image #%s',num2str(i)));

        if (mod(fam_first_side + i,2) == 0)
            log_msg('Side: left');
            left = true;
        else
            log_msg('Side: right');
            left = false;
        end
        
        if (i == 1 || total_looking > 5)
            WaitSecs(2);
        end

        total_looking = fam_image(fam_images{i},left);
        total_fam_looking = total_fam_looking + total_looking;
        
        log_msg(sprintf('Participant looked at image for %s seconds',num2str(total_looking)));

        if (total_looking < 5 && i < length(fam_images))
            log_msg('Insufficient looking. Showing attention getter');
            attention_getter();
        end 
    end 
    
    % TEST TRIALS
    
    % test trial #1
    WaitSecs(2);
    attention_getter();
    
    log_msg('Showing test trial #1');
    
    matching_image = find(cellfun(@(x) ~isempty(regexp(x, [fam_category_name '-test-1.*'])), {stimuli.name}));
    familiar_image = stimuli(matching_image).name;

    matching_image = find(cellfun(@(x) ~isempty(regexp(x, [novel_category_name '-test-1.*'])), {stimuli.name}));
    novel_image = stimuli(matching_image).name;

    if (novelty_side_at_test == 1)
        [ test1_novel test1_fam ] = test_images(novel_image,familiar_image);
    else
        [ test1_fam test1_novel ] = test_images(familiar_image,novel_image);
    end
    
    log_msg(sprintf('Test Trial #1 Novelty Preference: %s', num2str((test1_novel / (test1_novel + test1_fam)))));
    
    if (get_config('UseSecondTestTrial') == 1)
        % test trial #2
        WaitSecs(2);
        attention_getter();

        log_msg('Showing test trial #2');

        matching_image = find(cellfun(@(x) ~isempty(regexp(x, [fam_category_name '-test-1.*'])), {stimuli.name}));
        familiar_image = stimuli(matching_image).name;

        matching_image = find(cellfun(@(x) ~isempty(regexp(x, [novel_category_name '-test-1.*'])), {stimuli.name}));
        novel_image = stimuli(matching_image).name;

        if (novelty_side_at_test == 1)
            % these are reversed from test trial #1
            [ test2_fam test2_novel ] = test_images(familiar_image,novel_image);
        else
            [ test2_novel test2_fam ] = test_images(novel_image,familiar_image);
        end
        
        log_msg(sprintf('Test Trial #2 Novelty Preference: %s', num2str((test2_novel / (test2_novel + test2_fam)))));
    end

    %% POST-EXPERIMENT CLEANUP %%

    post_experiment(false);

%% HELPER FUNCTIONS %%
    function [value] = get_config (name)
        matching_param = find(cellfun(@(x) strcmpi(x, name), {config.Parameter}));
        value = [config(matching_param).Setting];
    end

    function [key_pressed] = key_pressed ()
        [~,~,keyCode] = KbCheck;
        
        if sum(keyCode) > 0
            key_pressed = true;
        else
            key_pressed = false;
        end
        
        % should we abort
        if strcmpi(KbName(keyCode),'ESCAPE')
            log_msg('Aborting experiment due to ESCAPE key press.');
            post_experiment(true);
        end
    end

    function [key_pressed] = left_key_pressed ()
        keyName = KbName('RightArrow');
        
        [~,~,keyCode] = KbCheck;
        
        if keyCode(keyName)
            key_pressed = true;
        else
            key_pressed = false;
        end
    end

    function [key_pressed] = right_key_pressed ()
        keyName = KbName('LeftArrow');
        
        [~,~,keyCode] = KbCheck;
        
        if keyCode(keyName)
            key_pressed = true;
        else
            key_pressed = false;
        end
    end
    
    function post_experiment (aborted)
        log_msg('Experiment ended');
        
        ListenChar(0);
        Screen('CloseAll');
        Screen('Preference', 'SuppressAllWarnings', 0);
        
        if (aborted == false)
            % get experimenter comments
            comments = inputdlg('Enter your comments about attentiveness, etc.:','Comments',3);

            % create empty data structure for results
            results = struct('key',{},'value',{});

            [ year, month, day, hour, minute, sec ] = datevec(now);
            end_time = [num2str(year) '-' num2str(month) '-' num2str(day) ' ' num2str(hour) ':' num2str(minute) ':' num2str(sec) ];

            results(length(results) + 1).key = 'Start Time';
            results(length(results)).value = start_time;
            results(length(results) + 1).key = 'End Time';
            results(length(results)).value = end_time;
            results(length(results) + 1).key = 'Status';

            if (aborted == true)
                results(length(results)).value = 'ABORTED!';
            else
                results(length(results)).value = 'Completed';
            end
            results(length(results) + 1).key = 'Experimenter';
            results(length(results)).value = experimenter;
            results(length(results) + 1).key = 'Subject Code';
            results(length(results)).value = subject_code;
            results(length(results) + 1).key = 'Subject Sex';
            results(length(results)).value = subject_sex;
            results(length(results) + 1).key = 'Subject Age';
            results(length(results)).value = subject_age;
            results(length(results) + 1).key = 'Comments';
            results(length(results)).value = comments{1};

            results(length(results) + 1).key = 'Order Code';
            results(length(results)).value = order_code;
            results(length(results) + 1).key = 'Familiarization Category';
            results(length(results)).value = fam_category_name;
            results(length(results) + 1).key = 'Fam First Side';
            results(length(results)).value = fam_first_side_name;
            results(length(results) + 1).key = 'Novelty Side Test Trial #1';
            results(length(results)).value = novelty_side_at_test_name;

            results(length(results) + 1).key = 'Total Familiarization Looking';
            results(length(results)).value = total_fam_looking;

            if (get_config('AssessPreference') == 1)
                results(length(results) + 1).key = 'Pre-trial Novelty Preference';
                results(length(results)).value = (pref_novel / (pref_fam + pref_novel));
            end

            results(length(results) + 1).key = 'Test #1 Novelty Preference';
            results(length(results)).value = (test1_novel / (test1_fam + test1_novel));

            if (get_config('UseSecondTestTrial') == 1)
                results(length(results) + 1).key = 'Test #2 Novelty Preference';
                results(length(results)).value = (test2_novel / (test2_fam + test2_novel));
            end

            for i = 1:length(fam_images)
                results(length(results) + 1).key = ['Fam Image ' i];
                results(length(results) + 1).value = fam_images{i};
            end
            
            % save session file
            filename = [base_dir 'sessions/' subject_code '.txt'];
            log_msg(sprintf('Saving results file to %s',filename));
            WriteStructsToText(filename,results)
            
            % save counterbalancer
            WriteStructsToText([base_dir 'counterbalancer.txt'], counterbalancer);
        else
            disp('Experiment aborted - results file not saved, but there is a log.');
        end
    end

    function [time_accumulated] = fam_image (image_name, left)
        % show for Xms
        time_required = (get_config('FamDuration') / 1000);
        
        log_msg(sprintf('Familiarization image to be showed for %s seconds',num2str(time_required)));
        
        % show the image
        filename = [base_dir 'stimuli/' image_name];
        log_msg(sprintf('Loading file from: %s',filename));
        [image map alpha] = imread(filename);
        % PNG support
        if ~isempty(regexp(image_name, '.*\.png'))
            log_msg('It is a PNG file');
            image(:,:,4) = alpha(:,:);
        end
        
        imtext = Screen('MakeTexture', wind, image);
        
        % position images
        texRect = Screen('Rect', imtext);
        
        if (left == true)
            l = (swidth / 4) - (texRect(3)/2);
            t = (sheight / 2) - (texRect(4)/2) + (sheight / 5);
            r = (swidth / 4) + (texRect(3)/2);
            b = (sheight / 2) + (texRect(4)/2) + (sheight / 5);
        else
            l = swidth - (swidth / 4) - (texRect(3)/2);
            t = (sheight / 2) - (texRect(4)/2) + (sheight / 5);
            r = swidth - (swidth / 4) + (texRect(3)/2);
            b = (sheight / 2) + (texRect(4)/2) + (sheight / 5);
        end
        
        Screen('DrawTexture', wind, imtext, [0 0 texRect(3) texRect(4)], [l t r b]);
        Screen('Flip', wind);
        Screen('Close', imtext);
        
        % play sound
        if (~isempty(get_config('PairedSound')))
            sound_file = [base_dir get_config('StimuliFolder') '/' get_config('PairedSound')];
            log_msg(sprintf('Loading sound from: %s',sound_file));
        else
            sound_file = false;
        end
        
        if (sound_file ~= false)
            [wav, freq] = wavread(sound_file);
            wav_data = wav';
            num_channels = size(wav_data,1);
            
            try
                % Try with the 'freq'uency we wanted:
                pahandle = PsychPortAudio('Open', [], [], 0, freq, num_channels);
            catch
                % Failed. Retry with default frequency as suggested by device:
                psychlasterror('reset');
                pahandle = PsychPortAudio('Open', [], [], 0, [], num_channels);
            end
            
            % Fill the audio playback buffer with the audio data 'wavedata':
            PsychPortAudio('FillBuffer', pahandle, wav_data);

            % Start audio playback for 'repetitions' repetitions of the sound data,
            % start it immediately (0) and wait for the playback to start, return onset
            % timestamp.
            PsychPortAudio('Start', pahandle, 1, 0, 1);
        end
        
        trial_start_time = GetSecs;
        time_accumulated = 0;
        keypress_start = 0;
        sound_replayed = 0;
        % loop indefinitely
        while (1 ~= 2)
            % track looking time
            if key_pressed()
                if (keypress_start == 0)
                    % start a keypress
                    keypress_start = GetSecs();
                end
            else
                if (keypress_start > 0)
                    % add to accumulated time
                    time_accumulated = time_accumulated + (GetSecs - keypress_start);
                end
                
                % reset keypress
                keypress_start = 0;
            end
            
            % play another sound?
            if ((GetSecs - trial_start_time) >= 10 && sound_replayed == 0)
                sound_replayed = 1;
                PsychPortAudio('Start', pahandle, 1, 0, 1);
            end
            
            % end logic
            if ((GetSecs - trial_start_time) > time_required)
                if (key_pressed())
                    time_accumulated = time_accumulated + (GetSecs - keypress_start);
                end
                
                break;
            end
        end
        
        Screen('Flip', wind);
        
        if (sound_file ~= false)
            PsychPortAudio('Stop', pahandle);

            % Close the audio device:
            PsychPortAudio('Close', pahandle);
        end
    end

    function [ l_time_accumulated r_time_accumulated ] = test_images (left_image_name, right_image_name)
        % get accumulated looking
        test_looking_required = (get_config('TestDuration') / 1000);
        
        log_msg(sprintf('Waiting for infant to accrue %s of looking',num2str(test_looking_required)));
        
        % show the image
        filename = [base_dir 'stimuli/' left_image_name];
        log_msg(sprintf('Loading left image file from: %s',filename));
        [left_image map alpha] = imread(filename);
        % PNG support
        if ~isempty(regexp(left_image_name, '.*\.png'))
            left_image(:,:,4) = alpha(:,:);
        end
        
        filename = [base_dir 'stimuli/' right_image_name];
        log_msg(sprintf('Loading right image file from: %s',filename));
        [right_image map alpha] = imread(filename);
        % PNG support
        if ~isempty(regexp(right_image_name, '.*\.png'))
            right_image(:,:,4) = alpha(:,:);
        end
        
        left_imtext = Screen('MakeTexture', wind, left_image);
        right_imtext = Screen('MakeTexture', wind, right_image);
        
        % position images
        texRect = Screen('Rect', left_imtext);
        
        left_l = (swidth / 4) - (texRect(3)/2);
        left_t = (sheight / 2) - (texRect(4)/2) + (sheight / 5);
        left_r = (swidth / 4) + (texRect(3)/2);
        left_b = (sheight / 2) + (texRect(4)/2) + (sheight / 5);
        
        right_l = swidth - (swidth / 4) - (texRect(3)/2);
        right_t = (sheight / 2) - (texRect(4)/2) + (sheight / 5);
        right_r = swidth - (swidth / 4) + (texRect(3)/2);
        right_b = (sheight / 2) + (texRect(4)/2) + (sheight / 5);
        
        Screen('DrawTexture', wind, left_imtext, [0 0 texRect(3) texRect(4)], [left_l left_t left_r left_b]);
        Screen('DrawTexture', wind, right_imtext, [0 0 texRect(3) texRect(4)], [right_l right_t right_r right_b]);
        
        Screen('Flip', wind);
        Screen('close', left_imtext);
        Screen('close', right_imtext);
        
        keypress_start = 0;
        press_direction = 0; %1 or 2 == L or R
        time_accumulated = 0;
        l_time_accumulated = 0;
        r_time_accumulated = 0;
        % loop indefinitely
        while (1 ~= 2)
            % look for a keypress
            % if both keys are pressed, we are in some sort of
            % transition and so we treat it as if NO keys are pressed
            if (key_pressed() && (left_key_pressed() ~= right_key_pressed()))
                if (keypress_start == 0)
                    % start a keypress
                    keypress_start = GetSecs();
                    
                    if (left_key_pressed())
                        press_direction = 1;
                    elseif (right_key_pressed())
                        press_direction = 2;
                    end
                else 
                    if ((time_accumulated + (GetSecs - keypress_start)) > test_looking_required)
                        % they have reached the looking criterion
                        
                        if (press_direction == 1)
                            l_time_accumulated = l_time_accumulated + (GetSecs - keypress_start);
                        elseif (press_direction == 2)
                            r_time_accumulated = r_time_accumulated + (GetSecs - keypress_start);
                        end
                            
                        break;
                    end
                end
            else
                if (keypress_start > 0)
                    % add to accumulated time
                    time_accumulated = time_accumulated + (GetSecs - keypress_start);
                    
                    if (press_direction == 1)
                        l_time_accumulated = l_time_accumulated + (GetSecs - keypress_start);
                    elseif (press_direction == 2)
                        r_time_accumulated = r_time_accumulated + (GetSecs - keypress_start);
                    end
                end
                
                % reset keypress
                keypress_start = 0;
            end
        end
        
        Screen('Flip', wind);
    end

    function attention_getter ()
        log_msg('Showing attention getter.');
        
        keypress_time_to_release = (get_config('StartDelay') / 1000);
        
        movie = Screen('OpenMovie', wind, [base_dir get_config('StimuliFolder') '/' get_config('AttentionGetter')]);
        
        % Start playback engine:
        Screen('PlayMovie', movie, 1);
        
        % set scale to 0 so it will be calculated
        texRect = 0;
        
        keypress_start = 0;
        % loop indefinitely
        while (1 ~= 2)
            % look for a keypress
            if key_pressed()
                if (keypress_start == 0)
                    % start a keypress
                    keypress_start = GetSecs();
                elseif (GetSecs - keypress_start > keypress_time_to_release)
                    % we have pressed the key for as long as we need to
                    % move on
                    Screen('PlayMovie', movie, 0);
                    Screen('CloseMovie', movie);
                    
                    Screen('Flip', wind);
                    
                    break
                end
            else
                % keypress is over so clear it (it's not cumulative)
                keypress_start = 0;
            end
            
            
            tex = Screen('GetMovieImage', wind, movie);
            
            % restart movie?
            if tex < 0
                %Screen('PlayMovie', movie, 0);
                Screen('SetMovieTimeIndex', movie, 0);
                %Screen('PlayMovie', movie, 1);
            else
                % Draw the new texture immediately to screen:
                if (texRect == 0)
                    texRect = Screen('Rect', tex);
                    
                    % calculate scale factors
                    scale_w = winRect(3) / texRect(3);
                    scale_h = winRect(4) / texRect(4);
                    
                    dstRect = CenterRect(ScaleRect(texRect, scale_w, scale_h), Screen('Rect', wind));
                end
                
                Screen('DrawTexture', wind, tex, [], dstRect);

                % Update display:
                Screen('Flip', wind);
                
                % Release texture:
                Screen('Close', tex);
            end
        end
        
        Screen('Flip', wind);
        log_msg('Attention getter ended');
    end

    function play_movie (name)
        filename = [base_dir get_config('StimuliFolder') '/' name];
        log_msg(sprintf('Playing movie: %s',filename));
        
        movie = Screen('OpenMovie', wind, filename);
        
        % Start playback engine:
        Screen('PlayMovie', movie, 1);
        
        % set these parameters so we can resize the video
        texRect = 0;
        
        % loop indefinitely
        while (1 ~= 2)
            tex = Screen('GetMovieImage', wind, movie);
            
            % restart movie?
            if tex < 0
                Screen('PlayMovie', movie, 0);
                Screen('CloseMovie', movie);
                Screen('Flip', wind);
                
                break
            else
                % Draw the new texture immediately to screen:
                if (texRect == 0)
                    texRect = Screen('Rect', tex);
                    
                    % calculate scale factors
                    scale_w = winRect(3) / texRect(3);
                    scale_h = winRect(4) / texRect(4);
                    
                    dstRect = CenterRect(ScaleRect(texRect, scale_w, scale_h), Screen('Rect', wind));
                end
                
                Screen('DrawTexture', wind, tex, [], dstRect);

                % Update display:
                Screen('Flip', wind);
                
                % Release texture:
                Screen('Close', tex);
            end
        end
        
        log_msg('Movie ended');
    end

    function create_log_file ()
        fileID = fopen([base_dir 'logs/' subject_code '-' start_time '.txt'],'w');
        fclose(fileID);
    end

    function log_msg (msg)
        fileID = fopen([base_dir 'logs/' subject_code '-' start_time '.txt'],'a');
        
        [ year, month, day, hour, minute, sec ] = datevec(now);
        timestamp = [num2str(year) '-' num2str(month) '-' num2str(day) ' ' num2str(hour) ':' num2str(minute) ':' num2str(sec) ];
        
        fprintf(fileID,'%s - %s\n',timestamp,msg);
        fclose(fileID);
        
        disp(sprintf('\n# %s\n',msg));
    end
end